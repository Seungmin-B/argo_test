# git + jenkins + helm + argo 데모 (전체 흐름)

이 저장소는 최소 구성의 전체 흐름을 담는다:
Git push -> Jenkins 빌드/테스트 -> Docker 빌드/푸시 -> ArgoCD 동기화 -> Helm으로 kind 배포.

포함 구성:
- app/ (Node.js 서비스 + Dockerfile)
- Jenkinsfile (CI 파이프라인)
- deploy/chart/ (Helm 차트)
- deploy/argocd/app.yaml (ArgoCD Application)
- deploy/local/ (kind + 로컬 레지스트리 오버라이드)
- scripts/kind-setup.sh (kind + 로컬 레지스트리 미러 구성)

사전 준비:
- docker, kind, kubectl, helm
- Jenkins 실행 중 (웹 UI 접근 가능)
- 클러스터에 ArgoCD 설치 가능

1회 설정:
- kind + 로컬 레지스트리 미러:
  - `./scripts/kind-setup.sh`
- 이 데모용 로컬 레지스트리:
  - `export REGISTRY=localhost:5001`

Jenkins (파이프라인 잡):
- New Item -> Pipeline
- Definition: "Pipeline script from SCM"
- SCM: Git
- Repo: `git@github.com:Seungmin-B/argo_test.git`
- Branch: `*/dev`
- Script Path: `Jenkinsfile`
- 환경변수:
  - `REGISTRY=localhost:5001`
  - `IMAGE_NAME=hello-demo`
  - `GIT_PUSH_BRANCH=deploy`
  - `GIT_USER_NAME=jenkins`
  - `GIT_USER_EMAIL=jenkins@localhost`

ArgoCD:
- 설치:
  - `kubectl create namespace argocd`
  - `kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml`
- 앱 적용:
  - `kubectl apply -f deploy/argocd/app.yaml`

전체 흐름:
- `dev` 브랜치에 `git push`
- Jenkins 실행:
  - npm install/test
  - docker build/push -> `localhost:5001/hello-demo:<tag>`
  - `deploy/local/values-local.yaml`의 tag를 업데이트하고 `deploy` 브랜치로 push
- ArgoCD가 `deploy` 브랜치 변경 감지 후 Helm 차트 동기화
- Kubernetes가 새 이미지를 가져와 Deployment 업데이트

로컬 확인:
- `kubectl get pods`
- `kubectl port-forward svc/hello-demo-hello-demo 8081:80`
- `curl http://localhost:8081/`

메모:
- Jenkins가 `deploy` 브랜치로 push할 수 있도록 GitHub Deploy Key에 write 권한이 필요하다.
- `deploy/argocd/app.yaml`에는 로컬 레지스트리 이미지를 위해 `../local/values-local.yaml`이 포함되어 있다.
- 8080 포트가 사용 중이면 8081 또는 다른 포트로 포워딩한다.
