package cmd

import (
	"aicontentcreationtools/pkg/recordingStudio"
	"fmt"
	"github.com/spf13/cobra"
	"os"
)

var (
	lineReadingOutput recordingStudio.LineReadingOutput
	lineReadingInput  recordingStudio.LineReadingInput
)

const defaultOutputDir = "output"

var lineRecordingCmd = &cobra.Command{
	Use:   "linerecording",
	Short: "Create line recordings",
	Long: `Create line recordings from input files
			--output (-o) is the directory to output files to (default: output)`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("[info] line-recording called")

		outputPath, err := lineReadingOutput.Path()
		if err != nil {
			fmt.Println("[error] invalid output path")
			fmt.Println(err)
			os.Exit(1)
			return
		}
		fmt.Println("[info] output directory:", outputPath)

		if len(args) == 0 {
			fmt.Println("[error] no input files")
			os.Exit(1)
			return
		}

		// arguments are all input files, so collect all files
		for _, arg := range args {
			if err := lineReadingInput.AddInputFile(arg); err != nil {
				fmt.Println("[error] invalid input file:", arg)
				fmt.Println(err)
				os.Exit(1)
				return
			}
		}

		if len(lineReadingInput.InputFiles) == 0 {
			fmt.Println("[error] no input files")
			os.Exit(1)
			return
		}

		for _, inputFile := range lineReadingInput.InputFiles {
			fmt.Println("[info] processing input file:", inputFile)
			script, err := lineReadingInput.GetScript(inputFile)
			if err != nil {
				fmt.Println("[error] invalid input file:", inputFile)
				fmt.Println(err)
				os.Exit(1)
				return
			}
			err = script.CreateLineReadRecordings(lineReadingOutput)
			if err != nil {
				fmt.Println("[error] failed to create line recordings for input file:", inputFile)
				fmt.Println(err)
				os.Exit(1)
				return
			}
		}
		fmt.Println("[info] done")
		os.Exit(0)
	},
}

func init() {
	lineRecordingCmd.Flags().StringVarP(&lineReadingOutput.PathInput, "output", "o", defaultOutputDir, fmt.Sprintf("Directory to output files to (default: %s)", defaultOutputDir))
}
