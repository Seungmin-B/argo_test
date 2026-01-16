# Local flow (kind + local registry mirror)

This directory provides a runnable local flow using kind and a local registry mirror.

Prereqs: docker, kind, kubectl, helm

Steps:
1) Create a local registry + kind cluster:
   - `scripts/kind-setup.sh`
2) Build and push:
   - `export REGISTRY=localhost:5001`
   - `docker build -t $REGISTRY/hello-demo:local app`
   - `docker push $REGISTRY/hello-demo:local`
3) Install with Helm:
   - `helm upgrade --install hello-demo deploy/chart -f deploy/local/values-local.yaml`

Notes:
- Jenkins: set `SKIP_PUSH=true` to skip registry push.
- ArgoCD: `argocd-app-local.yaml` shows how you'd point to the same repo with local overrides.
