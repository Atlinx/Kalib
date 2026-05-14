#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./build_docker.sh [image_name[:tag]]
# Example:
#   ./build_docker.sh kalib:latest

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="${1:-kalib:latest}"
cd $SCRIPT_DIR

echo "Building Docker image '$IMAGE_NAME'..."
docker build --progress=plain -f ./Dockerfile -t "$IMAGE_NAME" .
echo "Build complete: $IMAGE_NAME"
