#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

mkdir -p "$SCRIPT_DIR/dataset"
rm -rf "$SCRIPT_DIR/dataset/README.md"
echo "# Dataset
Please put the dataset in this folder.
" >> "$SCRIPT_DIR/dataset/README.md"

docker run --mount type=bind,src=$SCRIPT_DIR/dataset,target=/workspace/Kalib/dataset --mount type=bind,src=$SCRIPT_DIR/tools,target=/workspace/Kalib/tools -it kalib:latest
