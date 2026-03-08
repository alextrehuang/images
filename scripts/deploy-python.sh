#!/usr/bin/env bash
set -euo pipefail

# ------------------------------
# Configurable variables
# ------------------------------
BASE_IMAGE_NAME="base-python"
BASE_IMAGE_TAG="3.12-slim-bookworm"
TARGET_IMAGE_TAG="3.12"
REGISTRY="crpi-b92zro4mhsavduig.cn-shanghai.personal.cr.aliyuncs.com"
NAMESPACE="alextre"
DOCKERFILE_PATH="dockerfiles/python.Dockerfile"
FULL_TAG="$REGISTRY/$NAMESPACE/$BASE_IMAGE_NAME:$TARGET_IMAGE_TAG"
ARCHS=("amd64" "arm64")

# ------------------------------
# Aliyun login (optional)
# ------------------------------
if [ -n "${REGISTRY_USERNAME:-}" ] && [ -n "${REGISTRY_PASSWORD:-}" ]; then
    echo "Logging in to Aliyun registry..."
    echo "$REGISTRY_PASSWORD" | docker login --username "$REGISTRY_USERNAME" "$REGISTRY" --password-stdin
fi

# ------------------------------
# Clean old builders & containers
# ------------------------------
echo "Cleaning old buildx builders and leftover BuildKit containers..."
for builder in mybuilder modest_gauss; do
    if docker buildx inspect "$builder" >/dev/null 2>&1; then
        docker buildx rm "$builder"
        echo "Removed builder: $builder"
    fi
done

docker ps -a --filter "name=buildx_buildkit_" --format "{{.ID}}" | xargs -r docker rm -f

# ------------------------------
# Create new builder & install QEMU
# ------------------------------
echo "Creating new buildx builder..."
docker buildx create --name mybuilder --driver docker-container --use

echo "Installing QEMU emulation..."
docker run --rm --privileged tonistiigi/binfmt --install all

# ------------------------------
# Set long timeouts
# ------------------------------
export DOCKER_CLIENT_TIMEOUT=36000
export COMPOSE_HTTP_TIMEOUT=36000

# ------------------------------
# Function: retry docker push
# ------------------------------
retry_push() {
    local IMAGE="$1"
    local RETRIES=5
    local COUNT=0
    until docker push "$IMAGE"; do
        COUNT=$((COUNT+1))
        if [ $COUNT -ge $RETRIES ]; then
            echo "❌ Failed to push $IMAGE after $RETRIES attempts."
            return 1
        fi
        echo "⚠️  Retry push $IMAGE in 5s... ($COUNT/$RETRIES)"
        sleep 5
    done
}

# ------------------------------
# Build each architecture
# ------------------------------
for ARCH in "${ARCHS[@]}"; do
    echo "🚀 Building $ARCH..."

    # Proxy only during build
    export HTTP_PROXY="http://127.0.0.1:51573"
    export HTTPS_PROXY="http://127.0.0.1:51573"
    export http_proxy="http://127.0.0.1:51573"
    export https_proxy="http://127.0.0.1:51573"

    docker buildx build \
        --platform "linux/$ARCH" \
        --build-arg APT_MIRROR="https://mirrors.aliyun.com/debian/" \
        -f "$DOCKERFILE_PATH" \
        -t "$FULL_TAG-$ARCH" \
        --load \
        .

    # Disable proxy for push
    export HTTP_PROXY=""
    export HTTPS_PROXY=""
    export http_proxy=""
    export https_proxy=""

    echo "📦 Pushing $ARCH image..."
    retry_push "$FULL_TAG-$ARCH"
done

# ------------------------------
# Create multi-arch manifest
# ------------------------------
echo "🌐 Creating multi-arch manifest..."
docker buildx imagetools create -t "$FULL_TAG" \
    "${FULL_TAG}-amd64" \
    "${FULL_TAG}-arm64"

echo "✅ Multi-arch image $FULL_TAG built and pushed successfully!"