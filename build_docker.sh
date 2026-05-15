#!/usr/bin/env bash
#
# Usage:
#   ./build_docker.sh [image_name[:tag]]
# Example:
#   ./build_docker.sh kalib:latest

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
IMAGE_NAME="${1:-kalib:latest}"
cd $SCRIPT_DIR

echo "Building Docker image '$IMAGE_NAME'..."
docker build --progress=plain -f ./Dockerfile -t "$IMAGE_NAME" .
echo "Build complete: $IMAGE_NAME"
