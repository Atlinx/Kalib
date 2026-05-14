#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./build_docker.sh [image_name[:tag]]
# Example:
#   ./build_docker.sh kalib:latest

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="${1:-kalib:latest}"
DOCKERFILE_PATH="${DOCKERFILE_PATH:-$SCRIPT_DIR/Dockerfile}"
CONTEXT_DIR="${CONTEXT_DIR:-$SCRIPT_DIR}"

if ! command -v docker >/dev/null 2>&1; then
  echo "Error: docker is not installed or not in PATH." >&2
  exit 1
fi

echo "Building Docker image '$IMAGE_NAME' using '$DOCKERFILE_PATH'..."
docker build -f "$DOCKERFILE_PATH" -t "$IMAGE_NAME" "$CONTEXT_DIR"
echo "Build complete: $IMAGE_NAME"
