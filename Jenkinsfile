pipeline {
    agent any

    environment {
        // --- THIS PART IS CRUCIAL ---
        NEW_DOCKER_IMAGE_TAG = "${env.GIT_COMMIT}" // Or "${env.BUILD_NUMBER}"
        FULL_DOCKER_IMAGE = "rox007/samplenodeapp:${NEW_DOCKER_IMAGE_TAG}"
        // -----------------------------
    }

    stages {
        stage('Declarative: Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Clone Repository on Jenkins') {
            steps {
                // Ensure this is cloning 'main' if that's your primary branch
                git branch: 'main', url: 'https://github.com/AmarGangurde/Git-test.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    withEnv(["DOCKER_BUILDKIT=1"]) {
                        // --- THIS PART IS CRUCIAL ---
                        sh "docker build -t ${FULL_DOCKER_IMAGE} ."
                        // -----------------------------
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-id', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        withEnv(["DOCKER_CLI_PASSWORD=${DOCKER_PASSWORD}"]) {
                            sh 'echo "$DOCKER_CLI_PASSWORD" | docker login -u ${DOCKER_USERNAME} --password-stdin'
                        }
                        // --- THIS PART IS CRUCIAL ---
                        sh "docker push ${FULL_DOCKER_IMAGE}"
                        // -----------------------------
                    }
                }
            }
        }

        stage('Prepare Ansible LXC and Deploy') {
            steps {
                sshagent(credentials: ['sshagent']) { // Ensure 'sshagent' is the correct ID for your SSH credential
                    sh """
                        # We are sending the entire script to the remote Ansible LXC via SSH's stdin
                        ssh -o StrictHostKeyChecking=no root@10.100.127.152 "bash -s" << 'EOF'
                            # Commands to run on the remote Ansible LXC (10.100.127.152)
                            mkdir -p /root/my-project-repo

                            if [ -d /root/my-project-repo/.git ]; then
                                echo 'Repository already exists on Ansible LXC, pulling latest changes...'
                                cd /root/my-project-repo && git pull
                            else
                                echo 'Cloning repository to Ansible LXC for the first time...'
                                git clone https://github.com/AmarGangurde/Git-test.git /root/my-project-repo
                            fi

                            cd /root/my-project-repo && \\
                            ansible-playbook -i ansible/inventory.ini ansible/deploy.yaml \\
                            --extra-vars 'docker_image=${FULL_DOCKER_IMAGE} k8s_manifests_path=/root/my-project-repo/k3s'
                        EOF
                    """
                }
            }
        }
    }
}
