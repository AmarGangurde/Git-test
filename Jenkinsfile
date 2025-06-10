pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'rox007/samplenodeapp'
        DOCKER_CREDENTIALS_ID = 'dockerhub-id'
        IMAGE_TAG = 'latest'
        ANSIBLE_REMOTE_USER = 'root'
        ANSIBLE_REMOTE_HOST = '10.100.127.152'
        ANSIBLE_REMOTE_REPO_PATH = '/root/my-project-repo' // This is where the repo will be cloned on the Ansible LXC
        GIT_REPO_URL = 'https://github.com/AmarGangurde/Git-test.git' // Centralize your Git repo URL
    }

    stages {
        stage('Clone Repository on Jenkins') {
            steps {
                // This stage is still relevant if your Dockerfile or other build artifacts are in the repo
                git "${GIT_REPO_URL}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${IMAGE_TAG}")
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS_ID}") {
                        docker.image("${DOCKER_IMAGE}:${IMAGE_TAG}").push()
                    }
                }
            }
        }

        stage('Prepare Ansible LXC and Deploy') {
            steps {
                sshagent(['ansible-ssh-key']) { // This Jenkins credential provides the SSH key for root@10.100.127.152
                    sh """
                        # 1. Ensure the target directory exists on the Ansible LXC
                        ssh -o StrictHostKeyChecking=no ${ANSIBLE_REMOTE_USER}@${ANSIBLE_REMOTE_HOST} "mkdir -p ${ANSIBLE_REMOTE_REPO_PATH}"

                        # 2. Clone/Update the repository on the Ansible LXC
                        ssh -o StrictHostKeyChecking=no ${ANSIBLE_REMOTE_USER}@${ANSIBLE_REMOTE_HOST} "
                            if [ -d ${ANSIBLE_REMOTE_REPO_PATH}/.git ]; then
                                echo 'Repository already exists on Ansible LXC, pulling latest changes...'
                                cd ${ANSIBLE_REMOTE_REPO_PATH} && git pull
                            else
                                echo 'Cloning repository to Ansible LXC for the first time...'
                                git clone ${GIT_REPO_URL} ${ANSIBLE_REMOTE_REPO_PATH}
                            fi
                        "

                        # 3. Now, execute the Ansible playbook from the cloned repository on the Ansible LXC
                        ssh -o StrictHostKeyChecking=no ${ANSIBLE_REMOTE_USER}@${ANSIBLE_REMOTE_HOST} "
                            cd ${ANSIBLE_REMOTE_REPO_PATH} &&
                            ansible-playbook -i ansible/inventory.ini ansible/deploy.yaml \\
                            --extra-vars 'docker_image=${DOCKER_IMAGE}:${IMAGE_TAG} k8s_manifests_path=${ANSIBLE_REMOTE_REPO_PATH}/k3s'
                        "
                    """
                }
            }
        }
    }
}
