#!/usr/bin/env bash
set -euo pipefail

# ------------------------------
# Configurable variables
# ------------------------------
BASE_IMAGE_NAME="base-python"
BASE_IMAGE_TAG="3.12-slim-bookworm"
TARGET_IMAGE_TAG="3.12-slim-bookworm"
REGISTRY="crpi-b92zro4mhsavduig.cn-shanghai.personal.cr.aliyuncs.com"
NAMESPACE="alextre"
DOCKERFILE_PATH="python/Dockerfile"
FULL_TAG="$REGISTRY/$NAMESPACE/$BASE_IMAGE_NAME:$TARGET_IMAGE_TAG"

# ------------------------------
# Optional: Aliyun credentials
# ------------------------------
REGISTRY_USERNAME=${REGISTRY_USERNAME:-}
REGISTRY_PASSWORD=${REGISTRY_PASSWORD:-}


# ------------------------------
# Step 4: Build and push multi-arch base-python
# ------------------------------
echo " pushing multi-arch image $FULL_TAG..."
export DOCKER_CLIENT_TIMEOUT=600
export COMPOSE_HTTP_TIMEOUT=600

for arch in amd64 arm64; do
  echo "pushing $FULL_TAG-$arch"
  docker push "$FULL_TAG-$arch"
done

docker manifest create "$FULL_TAG" "$FULL_TAG-amd64" "$FULL_TAG-arm64"
docker manifest push "$FULL_TAG"

echo "✅ Multi-arch base-python built and pushed successfully!"