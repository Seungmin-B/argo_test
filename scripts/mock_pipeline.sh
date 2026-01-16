#!/usr/bin/env sh
set -eu

REGISTRY=${REGISTRY:-registry.local:5000}
IMAGE_NAME=${IMAGE_NAME:-hello-demo}
IMAGE_TAG=${IMAGE_TAG:-local}

printf "[mock] install...\n"
( cd app && npm install --no-audit --no-fund )

printf "[mock] test...\n"
( cd app && npm test )

printf "[mock] docker build (no push) ...\n"
( cd app && docker build -t ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} . )

if command -v helm >/dev/null 2>&1; then
  printf "[mock] helm template...\n"
  helm template hello-demo deploy/chart -f deploy/local/values-local.yaml > /tmp/hello-demo.yaml
  printf "[mock] rendered manifest: /tmp/hello-demo.yaml\n"
else
  printf "[mock] helm not installed; skip template.\n"
fi

printf "[mock] done.\n"
