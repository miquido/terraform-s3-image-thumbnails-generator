#!/bin/bash

set -e

ARGS=$(cat -)
INPUT_PATH=$(echo $ARGS | jq -r ".input_path")
OUTPUT_PATH=$(echo $ARGS | jq -r ".output_path")
WORKING_DIR=$(echo $ARGS | jq -r ".working_dir")

TEMPORARY_ZIP=".temporary.zip"


cd $INPUT_PATH

zip -rqX $TEMPORARY_ZIP ./* >>/tmp/log
cd $WORKING_DIR
mv $INPUT_PATH/$TEMPORARY_ZIP $OUTPUT_PATH

OUTPUT_HASH=$(cat $OUTPUT_PATH | openssl sha -binary -sha256 | base64)

jq -ncM \
  '{ "output_path": $output_path, "output_hash": $output_hash }' \
  --arg output_path "$OUTPUT_PATH" \
  --arg output_hash "$OUTPUT_HASH"
