#!/usr/bin/env bash
# set -x

SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
LINE_READING_SCHEMA="$SCRIPT_DIR/../schemas/line-reading-input-file.schema.json"
INPUT_FILES=()
OUTPUT_FILES=()

# tables
declare -A column_max_lengths
column_max_lengths[character]=0
column_max_lengths[voice_actor]=0
column_max_lengths[line_read_speed]=0
column_max_lengths[line]=0
column_padding=8

function print_table_header() {
  printf "%-$((column_max_lengths[character] + $column_padding))s" "Character"
  printf "%-$((column_max_lengths[line] + $column_padding))s" "Line"
  printf "%-$((column_max_lengths[line_read_speed] + $column_padding))s" "Line Read Speed"
  printf "%-$((column_max_lengths[voice_actor]))s\n" "Voice Actor"
  local total_length=$(( column_max_lengths[character] + column_max_lengths[voice_actor] + column_max_lengths[line_read_speed] + column_max_lengths[line] + (column_padding * 3) ))
  printf '=%.0s' $(seq 1 $total_length)
  printf '\n'
}
function print_table_row() {
  local character="$1"
  local voice_actor="$2"
  local line_read_speed="$3"
  local line="$4"

  printf "%-$((column_max_lengths[character] + $column_padding))s" "$character"
  printf "%-$((column_max_lengths[line] + $column_padding))s" "$line"
  printf "%-$((column_max_lengths[line_read_speed] + $column_padding))s" "$line_read_speed"
  printf "%-$((column_max_lengths[voice_actor]))s\n" "$voice_actor"
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

  echo "will process: $file"
  INPUT_FILES+=("$file")
}

function parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
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
  echo "$0 [files...]"
  echo "  [files...]       JSON or YAML files"
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

function prepare_for_table() {
  local input_file="$1"
  local -a lines

  # include header row in max length calculation
  update_max_lengths "Character" "Voice Actor" "Line Read Speed" "Line"

  mapfile -t lines < <(jq -r '.lines[] | "\(.character_name)|\(.line)|\(.line_read_speed // 1.0)"' "$input_file")

  for line_data in "${lines[@]}"; do
      IFS='|' read -r character_name line line_read_speed <<< "$line_data"
      voice_actor=$(lookup_character_voice_actor "$character_name" "$default_voice_actor" "$normalized_input_file_ref")
      update_max_lengths "$character_name" "$voice_actor" "$line_read_speed" "$line"
  done
}

function main() {
  check_json_schema_file "$LINE_READING_SCHEMA"

  parse_args "$@"

  if [[ ${#INPUT_FILES[@]} -eq 0 ]]; then
    echo "error: no input files passed into script"
    help
    exit 1
  fi

  for input_file in "${INPUT_FILES[@]}"; do
    echo "processing: $input_file"
    echo
    normalized_input_file_ref=$(normalize_input_file "$input_file")

    validate_json_with_json_schema "$LINE_READING_SCHEMA" "$normalized_input_file_ref"
    default_voice_actor=$(jq -r ".properties.characters.items.properties.voice_actor.default" "$LINE_READING_SCHEMA")
    default_line_read_speed=$(jq -r ".properties.lines.items.properties.line_read_speed.default" "$LINE_READING_SCHEMA")

    # serialized the JSON data into single line string, essentially for this script's processing
    mapfile -t lines < <(jq --arg default_line_read_speed "$default_line_read_speed" -r '.lines[] | "\(.character_name)|\(.line)|\(.line_read_speed // $default_line_read_speed)"' "$normalized_input_file_ref")

    echo "script:"
    echo
    prepare_for_table "$normalized_input_file_ref"
    print_table_header
    for line_data in "${lines[@]}"; do
        IFS="|" read -r character_name line line_read_speed <<< "$line_data"
        voice_actor=$(lookup_character_voice_actor "$character_name" "$default_voice_actor" "$normalized_input_file_ref")
        print_table_row "$character_name" "$voice_actor" "$line_read_speed" "$line"
    done
  done
}

main "$@"
