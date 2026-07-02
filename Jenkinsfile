pipeline {

    agent any

    environment {

        TF_IN_AUTOMATION = "true"
        KUBECONFIG = "/var/lib/jenkins/.kube/config"

    }

    stages {

        stage('Checkout') {

            steps {

                checkout scm

            }

        }

        stage('Verify Environment') {

            steps {

                sh '''
                docker --version
                terraform version
                kubectl version --client
                helm version
                minikube status
                '''

            }

        }

        stage('Terraform Init') {

            steps {

                dir('terraform') {

                    sh 'terraform init'

                }

            }

        }

        stage('Terraform Validate') {

            steps {

                dir('terraform') {

                    sh 'terraform validate'

                }

            }

        }

        stage('Terraform Plan') {

            steps {

                dir('terraform') {

                    sh 'terraform plan -out=tfplan'

                }

            }

        }

        stage('Terraform Apply') {

            steps {

                dir('terraform') {

                    sh 'terraform apply -auto-approve tfplan'

                }

            }

        }

        stage('Start Minikube') {

            steps {

                sh '''
                minikube status || minikube start --driver=docker
                '''

            }

        }

        stage('Build Image') {

            steps {

                sh '''

                minikube image build \
                -t flask-app:latest .

                '''

            }

        }

        stage('Deploy Kubernetes') {

            steps {

                sh '''

                kubectl apply -f k8s-app/

                '''

            }

        }

        stage('Verify Deployment') {

            steps {

                sh '''

                kubectl rollout status deployment/flask-app -n dev

                kubectl get pods -n dev

                kubectl get svc -n dev

                '''

            }

        }

        stage('Verify ArgoCD') {

            steps {

                sh '''

                kubectl get pods -n argocd

                '''

            }

        }

        stage('Verify Monitoring') {

            steps {

                sh '''

                kubectl get pods -n monitoring

                kubectl get svc -n monitoring

                '''

            }

        }

    }

    post {

        always {

            sh '''

            echo "Pipeline Finished"

            '''

        }

        success {

            echo 'Application Successfully Deployed'

        }

        failure {

            echo 'Pipeline Failed'

        }

    }

}