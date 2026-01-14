#!/usr/bin/env bash
#
# load-image-kind.sh
# Loads a local Docker image into a kind cluster
#
# Usage:
#   ./load-image-kind.sh <image-name:tag> [cluster-name]
#
# Example:
#   ./load-image-kind.sh my-app:latest
#   ./load-image-kind.sh my-app:v1.0.0 app-starter
#

set -e

IMAGE_NAME="${1}"
CLUSTER_NAME="${2:-app-starter}"

if [ -z "${IMAGE_NAME}" ]; then
  echo "Error: Image name is required"
  echo ""
  echo "Usage:"
  echo "  $0 <image-name:tag> [cluster-name]"
  echo ""
  echo "Example:"
  echo "  $0 my-app:latest"
  echo "  $0 my-app:v1.0.0 app-starter"
  exit 1
fi

echo "Loading image '${IMAGE_NAME}' into kind cluster '${CLUSTER_NAME}'..."

# Check if the cluster exists
if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
  echo "Error: Kind cluster '${CLUSTER_NAME}' does not exist"
  echo "Available clusters:"
  kind get clusters
  exit 1
fi

# Check if the image exists locally
if ! docker image inspect "${IMAGE_NAME}" > /dev/null 2>&1; then
  echo "Error: Docker image '${IMAGE_NAME}' not found locally"
  echo "Please build or pull the image first"
  exit 1
fi

# Load the image into kind
kind load docker-image "${IMAGE_NAME}" --name "${CLUSTER_NAME}"

echo ""
echo "✓ Image '${IMAGE_NAME}' loaded successfully into cluster '${CLUSTER_NAME}'"
echo ""
echo "You can now reference this image in your Helm values:"
echo ""
echo "  image:"
echo "    repository: ${IMAGE_NAME%:*}"
echo "    tag: \"${IMAGE_NAME##*:}\""
echo "    pullPolicy: IfNotPresent"
