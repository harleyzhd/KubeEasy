#!/usr/bin/env bash
#
# create-kind-cluster.sh
# Creates a local Kubernetes cluster using kind with ingress support
#

set -e

CLUSTER_NAME="${CLUSTER_NAME:-app-starter}"
CONFIG_FILE="${CONFIG_FILE:-kind/kind-config.yaml}"

echo "Creating kind cluster: ${CLUSTER_NAME}"
echo "Using config file: ${CONFIG_FILE}"

# Create the cluster
kind create cluster --name "${CLUSTER_NAME}" --config "${CONFIG_FILE}"

# Wait for cluster to be ready
echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Install NGINX Ingress Controller
echo "Installing NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for ingress controller to be ready
echo "Waiting for ingress controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

echo ""
echo "✓ Kind cluster '${CLUSTER_NAME}' is ready!"
echo ""
echo "To interact with your cluster:"
echo "  kubectl cluster-info --context kind-${CLUSTER_NAME}"
echo ""
echo "To delete the cluster:"
echo "  kind delete cluster --name ${CLUSTER_NAME}"
