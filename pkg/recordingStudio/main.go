package recordingStudio

import (
	"bytes"
	"encoding/json"
	"fmt"
	"github.com/xeipuuv/gojsonschema"
	"gopkg.in/yaml.v3"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
)

var LineReadingSchemaJson string

type LineReadingInput struct {
	InputFiles   []string
	fileToScript map[string]LineReadingScript
}

func (lri *LineReadingInput) GetScript(inputFilePath string) (LineReadingScript, error) {
	absInputFilePath, err := filepath.Abs(inputFilePath)
	if err != nil {
		return LineReadingScript{}, err
	}
	script, ok := lri.fileToScript[absInputFilePath]
	if !ok {
		return LineReadingScript{}, fmt.Errorf("input file not found")
	}
	return script, nil
}
func (lri *LineReadingInput) validateInputFile(inputFilePath string) ([]byte, error) {
	// exists?
	inputFileInfo, err := os.Stat(inputFilePath)
	if err != nil {
		return nil, err
	}

	// is file?
	if inputFileInfo.IsDir() {
		return nil, fmt.Errorf("input file is a directory, not a file")
	}

	// is json (.json) or yaml (.yaml, .yml)?
	if filepath.Ext(inputFilePath) != ".json" && filepath.Ext(inputFilePath) != ".yaml" && filepath.Ext(inputFilePath) != ".yml" {
		return nil, fmt.Errorf("input file is not a json or yaml file")
	}

	// JSON schema validates input file?
	fileBytes, err := os.ReadFile(inputFilePath)
	if err != nil {
		return nil, err
	}

	var jsonData interface{}
	if strings.HasSuffix(strings.ToLower(inputFilePath), ".json") {
		err = json.Unmarshal(fileBytes, &jsonData)
		if err != nil {
			return nil, err
		}
	} else if strings.HasSuffix(strings.ToLower(inputFilePath), ".yaml") || strings.HasSuffix(strings.ToLower(inputFilePath), ".yml") {
		if err := yaml.Unmarshal(fileBytes, &jsonData); err != nil {
			return nil, err
		}

		fileBytes, err = json.Marshal(jsonData)
		if err != nil {
			return nil, err
		}
	}

	schemaLoader := gojsonschema.NewStringLoader(LineReadingSchemaJson)
	documentLoader := gojsonschema.NewStringLoader(string(fileBytes))

	result, err := gojsonschema.Validate(schemaLoader, documentLoader)
	if err != nil {
		return nil, err
	}

	if !result.Valid() {
		for _, desc := range result.Errors() {
			fmt.Printf("- %s\n", desc)
		}
		return nil, fmt.Errorf("file does not match schema")
	}
	return fileBytes, nil
}
func (lri *LineReadingInput) AddInputFile(inputFilePath string) error {
	absInputFilePath, err := filepath.Abs(inputFilePath)
	if err != nil {
		return err
	}
	fileBytes, err := lri.validateInputFile(absInputFilePath)
	if err != nil {
		return err
	}

	var lineReadingScript LineReadingScript
	if err := json.Unmarshal(fileBytes, &lineReadingScript); err != nil {
		return err
	}
	for i, line := range lineReadingScript.Lines {
		if line.LineReadSpeed == 0 {
			lineReadingScript.Lines[i].LineReadSpeed = defaultLineReadSpeed
		}
	}
	for i, character := range lineReadingScript.Characters {
		if character.VoiceActor == "" {
			lineReadingScript.Characters[i].VoiceActor = defaultVoiceActor
		}
	}

	if lri.fileToScript == nil {
		lri.fileToScript = make(map[string]LineReadingScript)
	}
	lri.fileToScript[inputFilePath] = lineReadingScript

	lri.InputFiles = append(lri.InputFiles, absInputFilePath)
	return nil
}

type LineReadingOutput struct {
	PathInput string
}

func (lro LineReadingOutput) Path() (string, error) {
	absPath, err := filepath.Abs(lro.PathInput)
	if err != nil {
		return "", err
	}
	return absPath, nil
}
func (lro LineReadingOutput) Save() error {
	return nil
}

type LineReadingScript struct {
	DefaultOverrides         DefaultOverrides `json:"default_overrides"`
	Characters               []Character      `json:"characters"`
	Lines                    []Line           `json:"lines"`
	characterNameToCharacter map[string]Character
}

func (s *LineReadingScript) GetCharacterByCharacterName(characterName string) (*Character, error) {
	if s.characterNameToCharacter == nil {
		s.characterNameToCharacter = make(map[string]Character)
	}
	if character, ok := s.characterNameToCharacter[characterName]; ok {
		return &character, nil
	}
	for _, character := range s.Characters {
		if character.CharacterName == characterName {
			s.characterNameToCharacter[characterName] = character
			return &character, nil
		}
	}
	return nil, fmt.Errorf("character not found")
}
func convertLineToAudioFile(line Line, character Character, audioFilename string) error {
	_, err := os.Stat(audioFilename)
	if !os.IsNotExist(err) {
		fmt.Println("[info] audio file already exists:", audioFilename)
		return nil
	}
	payload := fmt.Sprintf(`{"model": "tts-1", "input": %q, "voice": %q, "speed": %f}`, line.Line, character.VoiceActor, line.LineReadSpeed)
	requestBody := bytes.NewBufferString(payload)

	req, err := http.NewRequest("POST", "https://api.openai.com/v1/audio/speech", requestBody)
	if err != nil {
		return err
	}

	openAIKey := os.Getenv("OPENAI_API_KEY")
	if openAIKey == "" {
		return fmt.Errorf("OPENAI_API_KEY environment variable not set")
	}
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", openAIKey))
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	responseBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return err
	}

	return os.WriteFile(audioFilename, responseBody, 0644)
}
func (s *LineReadingScript) CreateLineReadRecordings(output LineReadingOutput) error {
	outputPath, err := output.Path()
	if err != nil {
		return err
	}
	for i, line := range s.Lines {
		character, err := s.GetCharacterByCharacterName(line.CharacterName)
		if err != nil {
			return err
		}
		audioFilename := fmt.Sprintf("line-%d-char-%s.mp3", i+1, strings.ReplaceAll(character.CharacterName, " ", "_"))
		audioFilepath := filepath.Join(outputPath, audioFilename)
		fmt.Println(fmt.Sprintf("[info] line %v (%s %s): %s", i+1, character.CharacterName, character.VoiceActor, line.Line))
		if err := convertLineToAudioFile(line, *character, audioFilepath); err != nil {
			return err
		}
	}
	return nil
}

type DefaultOverrides struct {
	LineReadSpeed float64 `json:"line_read_speed"`
}
type Character struct {
	CharacterName       string `json:"character_name"`
	VoiceActor          string `json:"voice_actor"`
	CharacterMotivation string `json:"character_motivation"`
}
type Line struct {
	CharacterName string  `json:"character_name"`
	Line          string  `json:"line"`
	LineReadSpeed float64 `json:"line_read_speed"`
}

const (
	defaultVoiceActor    = "fable"
	defaultLineReadSpeed = 1.0
)
