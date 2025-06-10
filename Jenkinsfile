pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'rox007/samplenodeapp'
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
        stage('Deploy via Ansible') {
            steps {
                sshagent(['ansible-ssh-key']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no root@10.100.127.152 "
                            cd /root/my-project-repo &&
                            ansible-playbook -i ansible/inventory.ini ansible/deploy.yaml --extra-vars 'docker_image=$IMAGE_NAME:$TAG'
                        "
                    '''
                }
            }
        }
        }
    }
}
