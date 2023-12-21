#!/usr/bin/env bash
set -x

VOICE=onyx
SPEED=1.0
FILES=()
AUDIO_FILES=()

function parse_args() {
  echo "debug: args: $@"
  echo "count: $#"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -v|--voice)
        VOICE="$2"
        echo "debug: voice set to: $VOICE"
        shift 2
        ;;
      -s|--speed)
        SPEED="$2"
        echo "debug: speed set to: $SPEED"
        shift 2
        ;;
      -*|--*)
        echo "Unknown option: $1"
        help
        ;;
      *)
        echo "debug: file found: $1"
        FILES+=("$1")
        shift
        ;;
    esac
  done
  echo "Final voice: $VOICE"
  echo "Final speed: $SPEED"
  echo "Files to process: ${FILES[@]}"
}



function help() {
  echo "$0 --voice [voice] --speed [speed] [files...]"
  echo "  --voice [voice]  Voice to use for audio conversion"
  echo "  --speed [speed]  Speed at which to read the text"
  echo "  [files...]       Text files seperated by spaces to convert to audio"
  exit 1
}

function convert_line_to_audio() {
  local line="$1"
  local voice="$2"
  local speed="$3"
  local audio_filename="$4"

  curl https://api.openai.com/v1/audio/speech \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "tts-1",
      "input": "'"$line"'",
      "voice": "'"$voice"'",
      "speed": '"$speed"'
    }' \
    --output "$audio_filename"
}

  function convert_to_audio() {
    local file="$1"
    local voice="$2"
    local speed="$3"
    local filename="${file%.*}"
    local line_index=0
    local filter_complex_string=""

    while IFS= read -r line || [ -n "$line" ]; do
      if [[ -z "$line" ]]; then
        continue
      fi

      local audio_file="${filename}_${line_index}.mp3"
      convert_line_to_audio "$line" "$voice" "$speed" "$audio_file"
      AUDIO_FILES+=("$audio_file") # Collect the generated audio files

      filter_complex_string+="[${line_index}:a]atrim=duration=0.5[silence${line_index}];"
      filter_complex_string+="[${line_index}:a][silence${line_index}]concat[audio${line_index}];"
      line_index=$((line_index + 1))
    done < "$file"

    silence_duration=0.5  # Duration of silence in seconds
    silence_file="silence.mp3"

    # Create a silent audio file of the specified duration
    if [ ! -f "$silence_file" ]; then
        ffmpeg -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 -t "$silence_duration" "$silence_file"
    fi

    filter_complex_parts=()
    for index in "${!AUDIO_FILES[@]}"; do
        # For each audio file, specify that it should be followed by silence
        filter_complex_parts+=("[${index}:a][${#AUDIO_FILES[@]}:a]")  # Join audio file and silence
    done

    # Build the filter_complex string
    filter_complex_string="${filter_complex_parts[*]}concat=n=$((2 * ${#AUDIO_FILES[@]})):v=0:a=1[outa]"

    # Add all the input files to the ffmpeg command
    ffmpeg_inputs=""
    for audio_file in "${AUDIO_FILES[@]}"; do
        ffmpeg_inputs+="-i $audio_file "
    done
    # Add the silence file once because it will be reused
    ffmpeg_inputs+="-i $silence_file "

    ffmpeg $ffmpeg_inputs -filter_complex "$filter_complex_string" -map "[outa]" "${filename}-complete.mp3"
}

function main() {
  parse_args "$@"

  if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "No files to convert"
    help
  fi

  for file in "${FILES[@]}"; do
      if [[ -f "$file" ]]; then # Check if file exists
          convert_to_audio "$file" "$VOICE" "$SPEED"
      else
          echo "File not found: $file"
      fi
  done
}

main "$@"
