pipeline {
  agent any

  environment {
    REGISTRY = "${env.REGISTRY ?: 'registry.local:5000'}"
    IMAGE_NAME = "${env.IMAGE_NAME ?: 'hello-demo'}"
    IMAGE_TAG = "${env.IMAGE_TAG ?: env.BUILD_NUMBER}"
    GIT_PUSH_BRANCH = "${env.GIT_PUSH_BRANCH ?: 'deploy'}"
    GIT_USER_NAME = "${env.GIT_USER_NAME ?: 'jenkins'}"
    GIT_USER_EMAIL = "${env.GIT_USER_EMAIL ?: 'jenkins@localhost'}"
  }

  stages {
    stage('Install') {
      steps {
        sh 'cd app && npm install --no-audit --no-fund'
      }
    }

    stage('Test') {
      steps {
        sh 'cd app && npm test'
      }
    }

    stage('Docker Build') {
      steps {
        sh 'cd app && docker build -t ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} .'
      }
    }

    stage('Docker Push') {
      when {
        expression { return env.SKIP_PUSH != 'true' }
      }
      steps {
        sh 'docker push ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}'
      }
    }

    stage('Update Values') {
      when {
        expression { return env.SKIP_PUSH != 'true' }
      }
      steps {
        withCredentials([sshUserPrivateKey(credentialsId: 'github-ssh', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
          sh '''
            set -eu

            git config user.name "${GIT_USER_NAME}"
            git config user.email "${GIT_USER_EMAIL}"

            sed -i "s/^  tag: .*/  tag: \\"${IMAGE_TAG}\\"/" deploy/local/values-local.yaml

            git add deploy/local/values-local.yaml
            if git diff --cached --quiet; then
              echo "No values change to commit."
              exit 0
            fi

            git commit -m "ci: update image tag ${IMAGE_TAG} [skip ci]"
            GIT_SSH_COMMAND="ssh -i ${SSH_KEY} -o StrictHostKeyChecking=yes" \
              git push origin "HEAD:refs/heads/${GIT_PUSH_BRANCH}"
          '''
        }
      }
    }

    stage('Helm Package') {
      steps {
        sh 'helm dependency update deploy/chart || true'
        sh 'helm lint deploy/chart'
      }
    }
  }

  post {
    success {
      echo "Built ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
    }
  }
}
