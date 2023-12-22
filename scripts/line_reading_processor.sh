#!/usr/bin/env bash
set -x

SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
LINE_READING_SCHEMA="$SCRIPT_DIR/../schemas/line-reading-input-file.schema.json"
INPUT_FILES=()
OUTPUT_FILES=()

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

function main() {
  check_json_schema_file "$LINE_READING_SCHEMA"

  parse_args "$@"

  if [[ ${#INPUT_FILES[@]} -eq 0 ]]; then
    echo "error: no input files"
    help
    exit 1
  fi

  for input_file in "${INPUT_FILES[@]}"; do
    echo "processing: $input_file"
    echo
    normalized_input_file=$(normalize_input_file "$input_file")

    validate_json_with_json_schema "$LINE_READING_SCHEMA" "$normalized_input_file"
    default_voice_actor=$(jq -r ".properties.characters.items.properties.voice_actor.default" "$LINE_READING_SCHEMA")
    default_line_read_speed=$(jq -r ".properties.lines.items.properties.line_read_speed.default" "$LINE_READING_SCHEMA")

    jq -r '.lines[] | "\(.character_name)|\(.line)"' "$normalized_input_file" | while IFS="|" read -r character_name line; do
      voice_actor=$(jq -r ".characters[] | select(.character_name == \"$character_name\") | .voice_actor" "$normalized_input_file")
      echo "$character_name ($voice_actor): $line"
    done
  done
}

main "$@"
