#!/usr/bin/env bash
# set -x

SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
LINE_READING_SCHEMA="$SCRIPT_DIR/../schemas/line-reading-input-file.schema.json"
INPUT_FILES=()
OUTPUT_FILES=()
OUTPUT_DIRECTORY="$SCRIPT_DIR/../output"

function data_dir_file() {
  local file="$1"
  echo "$OUTPUT_DIRECTORY/$file"
}

# used for file naming scheme
declare -A character_line_count
leading_zeros_for_numbers=3
# tables
declare -A column_max_lengths
column_max_lengths[character]=0
column_max_lengths[voice_actor]=0
column_max_lengths[line_read_speed]=0
column_max_lengths[line]=0
column_max_lengths[audio_filename]=0
column_padding=2

function print_table_header() {
  printf "%-$((column_max_lengths[character] + $column_padding))s" "Character"
  printf "%-$((column_max_lengths[line] + $column_padding))s" "Line"
  printf "%-$((column_max_lengths[line_read_speed] + $column_padding))s" "Line Read Speed"
  printf "%-$((column_max_lengths[voice_actor] + $column_padding))s" "Voice Actor"
  printf "%-$((column_max_lengths[audio_filename]))s\n" "Out Audio"
}
function print_table_row() {
  local character="$1"
  local voice_actor="$2"
  local line_read_speed="$3"
  local line="$4"
  local audio_filename="$5"

  printf "%-$((column_max_lengths[character] + $column_padding))s" "$character"
  printf "%-$((column_max_lengths[line] + $column_padding))s" "$line"
  printf "%-$((column_max_lengths[line_read_speed] + $column_padding))s" "$line_read_speed"
  printf "%-$((column_max_lengths[voice_actor] + $column_padding))s" "$voice_actor"
  printf "%-$((column_max_lengths[audio_filename]))s\n" "$audio_filename"
}
function prepare_for_table() {
  local input_file="$1"
  local -a lines

  # include header row in max length calculation
  update_max_lengths "Character" "Voice Actor" "Line Read Speed" "Line" "Out Audio"

  mapfile -t lines < <(jq -r '.lines[] | "\(.character_name)|\(.line)|\(.line_read_speed // 1.0)"' "$input_file")

  for line_data in "${lines[@]}"; do
      IFS='|' read -r character_name line line_read_speed <<< "$line_data"
      voice_actor=$(lookup_character_voice_actor "$character_name" "$default_voice_actor" "$normalized_input_file_ref")
      update_max_lengths "$character_name" "$voice_actor" "$line_read_speed" "$line"
  done
}
function update_max_lengths() {
    local character="$1"
    local voice_actor="$2"
    local line_read_speed="$3"
    local line="$4"

    [[ ${#character} -gt ${column_max_lengths[character]} ]] && column_max_lengths[character]=${#character}
    [[ ${#voice_actor} -gt ${column_max_lengths[voice_actor]} ]] && column_max_lengths[voice_actor]=${#voice_actor}
    [[ ${#line_read_speed} -gt ${column_max_lengths[line_read_speed]} ]] && column_max_lengths[line_read_speed]=${#line_read_speed}
    [[ ${#line} -gt ${column_max_lengths[line]} ]] && column_max_lengths[line]=${#line}
}
# /tables

function add_input_file() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    echo "error: not file $file"
    exit 1
  fi

  INPUT_FILES+=("$file")
}

function parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--data-directory)
        OUTPUT_DIRECTORY="$2"
        shift
        ;;
      -h|--help)
        help
        exit 0
        ;;
      -*|--*)
        echo "unknown option: $1"
        help
        exit 1
        ;;
      *)
        add_input_file "$1"
        shift
        ;;
    esac
  done
}

function help() {
  echo "$0 [-d output_directory] [files...]"
  echo "  -h/--help                 Show this help message"
  echo "  -d/--data-directory       Directory to output files to (default: $OUTPUT_DIRECTORY)"
  echo "  [files...]                JSON or YAML files"
  echo
}

function validate_json_with_json_schema() {
  local schema_file="$1"
  local tmp_json_file="$2"

  if ! ajv validate -s "$schema_file" -d "$tmp_json_file" > /dev/null; then
    echo "command: ajv validate -s "$schema_file" -d "$tmp_json_file""
    echo "error: json file is not valid according to json schema (file $tmp_json_file, schema $schema_file)"
    exit 1
  fi
}

function check_json_file() {
  local json_file="$1"
  # is file?
  if [[ ! -f "$json_file" ]]; then
    echo "error: json file not found: $json_file"
    exit 1
  fi

  # is json?
  if ! jq . "$json_file" > /dev/null; then
    echo "error: json file is not valid json: $json_file"
    exit 1
  fi
}

function check_json_schema_file() {
  local schema_file="$1"

  check_json_file "$schema_file"

  # is json schema?
  if ! ajv compile -s "$schema_file" > /dev/null; then
    echo "error: json schema file is not a valid json schema: $schema_file"
    exit 1
  fi
}

function normalize_input_file() {
  local input_file="$1"
  local normalized=""

  if [[ "$input_file" == *.yaml || "$input_file" == *.yml ]]; then
    local tmp_json_file="/tmp/$(basename "$input_file").json"
    yq eval -p yaml -o json "$input_file" > "$tmp_json_file"
    normalized="$tmp_json_file"
  else
    normalized="$input_file"
  fi

  echo "$normalized"
}

function lookup_character_voice_actor() {
  local character_name="$1"
  local default_voice_actor="$2"
  local input_file="$3"
  local voice_actor=""

  voice_actor=$(jq -r --arg character_name "$character_name" '.characters[] | select(.character_name == $character_name).voice_actor // empty' "$input_file")

  # If no voice_actor is found, use the default
  if [[ -z $voice_actor ]]; then
    voice_actor="$default_voice_actor"
  fi

  echo "$voice_actor"
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
    --output "$audio_filename" > /dev/null 2>&1
}

function main() {
  check_json_schema_file "$LINE_READING_SCHEMA"

  parse_args "$@"

  if [[ ${#INPUT_FILES[@]} -eq 0 ]]; then
    echo "error: no input files passed into script"
    help
    exit 1
  fi

  if [[ ! -d "$OUTPUT_DIRECTORY" ]]; then
    mkdir -p "$OUTPUT_DIRECTORY"
  fi

  for input_file in "${INPUT_FILES[@]}"; do
    echo "processing: $input_file"
    echo
    normalized_input_file_ref=$(normalize_input_file "$input_file")

    validate_json_with_json_schema "$LINE_READING_SCHEMA" "$normalized_input_file_ref"
    # get the default values from the JSON schema itself
    default_voice_actor=$(jq -r ".properties.characters.items.properties.voice_actor.default" "$LINE_READING_SCHEMA")
    default_line_read_speed=""
    optional_line_read_speed_override=$(jq -r ".default_overrides.line_read_speed // empty" "$normalized_input_file_ref")
    if [[ -n "$optional_line_read_speed_override" ]]; then
      default_line_read_speed="$optional_line_read_speed_override"
    else
      default_line_read_speed=$(jq -r ".properties.lines.items.properties.line_read_speed.default" "$LINE_READING_SCHEMA")
    fi
    default_line_takes=$(jq -r ".properties.lines.items.properties.desired_takes.default" "$LINE_READING_SCHEMA")

    # serialized the JSON assets into single line string, essentially for this script's processing
    mapfile -t lines < <(jq --arg default_line_read_speed "$default_line_read_speed" -r '.lines[] | "\(.character_name)|\(.line)|\(.line_read_speed // $default_line_read_speed)"' "$normalized_input_file_ref")

    filename_no_ext=$(basename "$normalized_input_file_ref")
    while [[ $filename_no_ext == *.* ]]; do
      filename_no_ext=${filename_no_ext%.*}
    done
    input_file_output_dir="$OUTPUT_DIRECTORY/$filename_no_ext"
    mkdir -p "$input_file_output_dir"

    prepare_for_table "$normalized_input_file_ref"
    print_table_header
    local line_index=1
    for line_data in "${lines[@]}"; do
        IFS="|" read -r character_name line line_read_speed <<< "$line_data"
        voice_actor=$(lookup_character_voice_actor "$character_name" "$default_voice_actor" "$normalized_input_file_ref")

        sanitized_character_name=$(echo "$character_name" | tr '[:space:]' '_' | tr -d '[:punct:]')
        if [[ -z "${character_line_count[$sanitized_character_name]}" ]]; then
            character_line_count[$sanitized_character_name]=1
        else
            ((character_line_count[$sanitized_character_name]++))
        fi
        local formatted_character_line_index=$(printf "%0${leading_zeros_for_numbers}d" "${character_line_count[$sanitized_character_name]}")
        local formatted_line_index=$(printf "%0${leading_zeros_for_numbers}d" "$line_index")
        local formatted_line_read_speed=$(echo "$line_read_speed")

        audio_filename="${input_file_output_dir}/line-${formatted_line_index}-${sanitized_character_name}-char-line-${formatted_character_line_index}-line-read-speed-${formatted_line_read_speed}.mp3"
        if [[ ! -f "$audio_filename" ]]; then
            convert_line_to_audio "$line" "$voice_actor" "$line_read_speed" "$audio_filename"
        fi

        print_table_row "$character_name" "$voice_actor" "$line_read_speed" "$line" "$(basename "$audio_filename")"

        ((line_index++))
    done
  done
}

main "$@"
