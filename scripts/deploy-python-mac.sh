#!/usr/bin/env bash
set -euo pipefail

# ------------------------------
# Configurable variables
# ------------------------------
BASE_IMAGE_NAME="base-python"
TARGET_IMAGE_TAG="3.11"
DOCKERFILE_PATH="dockerfiles/python-311.Dockerfile"
FULL_TAG="$BASE_IMAGE_NAME:$TARGET_IMAGE_TAG"

# ------------------------------
# Optional: set proxy if needed
# ------------------------------
# export HTTP_PROXY="http://127.0.0.1:51573"
# export HTTPS_PROXY="http://127.0.0.1:51573"
# export http_proxy="http://127.0.0.1:51573"
# export https_proxy="http://127.0.0.1:51573"

# ------------------------------
# Build ARM64 image locally
# ------------------------------
echo "🚀 Building local ARM64 image $FULL_TAG..."
docker build \
    -f "$DOCKERFILE_PATH" \
    -t "$FULL_TAG" \
    .

# ------------------------------
# Done
# ------------------------------
echo "✅ ARM64 image $FULL_TAG built locally!"