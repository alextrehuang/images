#!/usr/bin/env bash
set -euo pipefail

# ------------------------------
# Configurable variables
# ------------------------------
IMAGE_NAME=${IMAGE_NAME:-base-python}
IMAGE_TAG=${IMAGE_TAG:-3.12}
DOCKERFILE_PATH=${DOCKERFILE_PATH:-dockerfiles/python.Dockerfile}
BUILD_CONTEXT=${BUILD_CONTEXT:-.}
LIBRARY=${LIBRARY:-base}
APT_MIRROR=${APT_MIRROR:-https://mirrors.aliyun.com/debian/}
HOST_ARCH="$(uname -m)"
case "$HOST_ARCH" in
    arm64|aarch64) DEFAULT_PLATFORM="linux/arm64" ;;
    x86_64|amd64) DEFAULT_PLATFORM="linux/amd64" ;;
    *)
        echo "Unsupported host architecture: $HOST_ARCH" >&2
        exit 1
        ;;
esac
PLATFORMS=${PLATFORMS:-$DEFAULT_PLATFORM}
FULL_TAG="${LIBRARY}/${IMAGE_NAME}:${IMAGE_TAG}"

echo "🚀 Building $FULL_TAG (platform $PLATFORMS)..."

docker build \
    --build-arg APT_MIRROR="$APT_MIRROR" \
    -f "$DOCKERFILE_PATH" \
    -t "$FULL_TAG" \
    "$BUILD_CONTEXT"

echo "✅ Local image ready: $FULL_TAG"
