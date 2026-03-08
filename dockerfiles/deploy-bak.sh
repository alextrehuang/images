#!/usr/bin/env bash
set -euo pipefail

# ------------------------------
# Configurable defaults
# ------------------------------
DEFAULT_IMAGE_TAG="3.12"
IMAGE_NAMESPACE="alextre"
IMAGE_NAME=${IMAGE_NAME:-base-python}
IMAGE_TAG=${IMAGE_TAG:-$DEFAULT_IMAGE_TAG}
REGISTRY=${REGISTRY:-crpi-b92zro4mhsavduig.cn-shanghai.personal.cr.aliyuncs.com}
REGISTRY_USERNAME=${REGISTRY_USERNAME:-}
REGISTRY_PASSWORD=${REGISTRY_PASSWORD:-}
DOCKERFILE_PATH=${DOCKERFILE_PATH:-base-python/Dockerfile}

# Full image tag
FULL_TAG="$REGISTRY/$IMAGE_NAMESPACE/$IMAGE_NAME:$IMAGE_TAG"

# Optional login (for push)
if [ -n "$REGISTRY_USERNAME" ] && [ -n "$REGISTRY_PASSWORD" ]; then
    echo "$REGISTRY_PASSWORD" | docker login --username "$REGISTRY_USERNAME" "$REGISTRY" --password-stdin
fi

# ------------------------------
# Build locally (ARM64 for Mac)
# ------------------------------
echo "Building $FULL_TAG from $DOCKERFILE_PATH..."
docker buildx build --platform=linux/amd64,linux/arm64 -f "$DOCKERFILE_PATH" -t "$FULL_TAG" .

# ------------------------------
# Optional push (if credentials provided)
# ------------------------------
if [ -n "$REGISTRY_USERNAME" ] && [ -n "$REGISTRY_PASSWORD" ]; then
    echo "Pushing $FULL_TAG..."
    docker push "$FULL_TAG"
fi

echo "✅ Build completed: $FULL_TAG"