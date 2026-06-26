pipeline {
    agent any

    stages {

        stage('Clone') {
            steps {
                echo 'Repository cloned by Jenkins.'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'cd k8s-app && docker build -t flask-app:v1 .'
            }
        }

        stage('Verify Docker Image') {
            steps {
                sh 'docker images'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                kubectl apply -f k8s-app/k8s/deployment.yaml
                kubectl apply -f k8s-app/k8s/service.yaml
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh 'kubectl get pods -n dev'
                sh 'kubectl get svc -n dev'
            }
        }
    }
}
