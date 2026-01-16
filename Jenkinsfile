pipeline {
  agent any

  environment {
    REGISTRY = "${env.REGISTRY ?: 'registry.local:5000'}"
    IMAGE_NAME = "${env.IMAGE_NAME ?: 'hello-demo'}"
    IMAGE_TAG = "${env.IMAGE_TAG ?: env.BUILD_NUMBER}"
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
