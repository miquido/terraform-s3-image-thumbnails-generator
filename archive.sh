#!/bin/bash

set -e

ARGS=$(cat -)
INPUT_PATH=$(echo "$ARGS" | jq -r ".input_path")
OUTPUT_PATH=$(echo "$ARGS" | jq -r ".output_path")
WORKING_DIR="$PWD"
TEMPORARY_ZIP=".temporary.zip"

cd "$INPUT_PATH"
zip -rqX "$TEMPORARY_ZIP" ./* >>/tmp/log

cd "$WORKING_DIR"
mv "$INPUT_PATH/$TEMPORARY_ZIP" "$OUTPUT_PATH"

jq -ncM '{ "output_path": $output_path }' --arg output_path "$OUTPUT_PATH"
