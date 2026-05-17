#!/bin/bash
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

mkdir -p "$SCRIPT_DIR/dataset"
rm -rf "$SCRIPT_DIR/dataset/README.md"
echo "# Dataset
Please put the dataset in this folder.
" >> "$SCRIPT_DIR/dataset/README.md"

docker run --gpus all --mount type=bind,src=$SCRIPT_DIR/dataset,target=/workspace/Kalib/dataset --mount type=bind,src=$SCRIPT_DIR/tools,target=/workspace/Kalib/tools -it kalib:latest
