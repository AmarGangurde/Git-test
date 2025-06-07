pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'rox007/sampleNodeApp'
        DOCKER_CREDENTIALS_ID = 'dockerhub-id'
    }

    stages {
        stage('Clone Repository') {
            steps {
                git 'https://github.com/AmarGangurde/Git-test.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}")
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS_ID}") {
                        docker.image("${DOCKER_IMAGE}").push('latest')
                    }
                }
            }
        }
    }
}
