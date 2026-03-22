#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME=${IMAGE_NAME:-ai-runtime}
IMAGE_TAG=${IMAGE_TAG:-latest}
LIBRARY=${LIBRARY:-base}
DOCKERFILE_PATH=${DOCKERFILE_PATH:-dockerfiles/ai.Dockerfile}
PLATFORMS=${PLATFORMS:-linux/arm64}
BUILD_CONTEXT=${BUILD_CONTEXT:-.}

FULL_TAG="${LIBRARY}/${IMAGE_NAME}:${IMAGE_TAG}"

if [ ! -f "$DOCKERFILE_PATH" ]; then
    FALLBACK="dockerfiles/ai.Dockerffile"
    if [ -f "$FALLBACK" ]; then
        echo "Warning: $DOCKERFILE_PATH not found, using $FALLBACK instead."
        DOCKERFILE_PATH="$FALLBACK"
    else
        echo "Error: Dockerfile $DOCKERFILE_PATH not found." >&2
        exit 1
    fi
fi

export DOCKER_CLIENT_TIMEOUT=${DOCKER_CLIENT_TIMEOUT:-3600}
export COMPOSE_HTTP_TIMEOUT=${COMPOSE_HTTP_TIMEOUT:-3600}

if [ -n "${BUILD_ARGS:-}" ]; then
    read -r -a EXTRA_BUILD_ARGS <<< "${BUILD_ARGS}"
else
    EXTRA_BUILD_ARGS=()
fi

echo "Building local image $FULL_TAG for $PLATFORMS..."
BUILD_CMD=(
    docker buildx build
    --platform "$PLATFORMS"
    -f "$DOCKERFILE_PATH"
    -t "$FULL_TAG"
    --load
)

if [ ${#EXTRA_BUILD_ARGS[@]} -gt 0 ]; then
    BUILD_CMD+=("${EXTRA_BUILD_ARGS[@]}")
fi

BUILD_CMD+=("$BUILD_CONTEXT")

"${BUILD_CMD[@]}"

echo "Done. Local image available: $FULL_TAG"
