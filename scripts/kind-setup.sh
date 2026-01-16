#!/usr/bin/env sh
set -eu

REGISTRY_NAME=${REGISTRY_NAME:-kind-registry}
REGISTRY_PORT=${REGISTRY_PORT:-5001}
CLUSTER_NAME=${CLUSTER_NAME:-kind}

if ! docker ps --format '{{.Names}}' | grep -q "^${REGISTRY_NAME}$"; then
  docker run -d --restart=always -p "${REGISTRY_PORT}:5000" --name "${REGISTRY_NAME}" registry:2
fi

if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
  kind create cluster --name "${CLUSTER_NAME}" --config deploy/local/kind-config.yaml
fi

if ! docker network inspect kind >/dev/null 2>&1; then
  echo "kind network not found; is the cluster running?" >&2
  exit 1
fi

if ! docker network inspect kind --format '{{json .Containers}}' | grep -q "${REGISTRY_NAME}"; then
  docker network connect kind "${REGISTRY_NAME}" || true
fi

cat <<EOF2 | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${REGISTRY_PORT}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF2

echo "kind cluster '${CLUSTER_NAME}' ready with local registry at localhost:${REGISTRY_PORT}";
