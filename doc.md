# Terraform + Jenkins + Minikube CI/CD Project

## Phase 1 to Phase 5 Documentation

### Project Goal

Build a complete DevOps project using:

* Terraform
* AWS VPC
* AWS EC2
* S3 Backend
* Jenkins
* Docker
* Kubernetes (Minikube)
* ArgoCD
* Prometheus
* Grafana

### Project Constraint

Since DockerHub and ECR are not being used:

* Docker images will be built locally.
* Images will be loaded directly into Minikube.
* Kubernetes deployments will use local images.
* CI/CD will be implemented using Jenkins + Minikube.

---

# Phase 1: Prerequisites

## Generate SSH Key

```bash
ssh-keygen -t rsa -b 4096
```

Purpose:

* Creates public/private key pair.
* Public key uploaded to AWS.
* Private key used to connect to EC2.

---

## Verify AWS Access

```bash
aws sts get-caller-identity
```

Purpose:

* Verifies AWS CLI configuration.
* Confirms account access.

---

## Create S3 Backend Bucket

```bash
aws s3 mb s3://bucket_name
```

Verify:

```bash
aws s3 ls
```

Purpose:

* Stores Terraform state remotely.
* Enables centralized state management.

---

## Verify Existing Key Pairs

```bash
aws ec2 describe-key-pairs
```

Purpose:

* Verify uploaded key pair.
* Use same key in Terraform.

---

# Phase 2: Terraform Backend Setup

## Backend Configuration

Terraform state stored in S3.

Benefits:

* State is not stored locally.
* Team collaboration supported.
* State recovery possible.

Example:

```hcl
terraform {
  backend "s3" {
    bucket = "bucket_name"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}
```

---

# Phase 3: Terraform Infrastructure

## Resources Created

### VPC Module

Creates:

* VPC
* Internet Gateway
* Route Table
* Route Table Association

### Subnet

Creates:

* Public subnet

### Security Group

Allows:

* SSH (22)
* Jenkins (8080)
* Kubernetes NodePort Range
* Grafana
* Prometheus

### EC2 Module

Creates:

* Jenkins Server
* Minikube Host

---

## Terraform Commands

Initialize:

```bash
terraform init
```

Validate:

```bash
terraform validate
```

Plan:

```bash
terraform plan
```

Apply:

```bash
terraform apply
```

Verify Outputs:

```bash
terraform output
```

Verify State:

```bash
terraform state list
```

---

# Phase 4: Dynamic Ubuntu AMI

## Initial Attempt

SSM Parameter:

```bash
aws ssm get-parameter \
--name "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id" \
--region ap-south-1 \
--query "Parameter.Value" \
--output text
```

Used to fetch latest Ubuntu AMI.

---

## Verify AMI

```bash
aws ec2 describe-images \
--image-ids ami-xxxxxxxxxxxxxxxxx \
--region ap-south-1
```

Purpose:

* Verify AMI details.
* Confirm architecture.
* Confirm region availability.

---

# Phase 5: EC2 Bootstrap (User Data)

## Objective

Automatically install:

* Java
* Git
* Docker
* Jenkins
* Kubectl
* Helm
* Minikube

---

## Important Learning

### Issue 1

Jenkins GPG Key Error

Error:

```text
NO_PUBKEY 7198F4B714ABFC68
```

Cause:

* Jenkins repository key changed.

Resolution:

```bash
sudo apt-key adv \
--keyserver keyserver.ubuntu.com \
--recv-keys 7198F4B714ABFC68
```

---

### Issue 2

Jenkins Failed to Start

Error:

```text
Running with Java 17
which is older than the minimum required version (Java 21)
```

Cause:

* Latest Jenkins requires Java 21.

Incorrect:

```bash
apt install openjdk-17-jdk -y
```

Correct:

```bash
apt install openjdk-21-jdk -y
```

---

## Correct Post-Deployment Verification

After connecting to EC2:

```bash
sudo cloud-init status

java -version

docker version

git --version

sudo systemctl status jenkins

sudo systemctl status docker

kubectl version --client

helm version

minikube version
```

---

## Verify Cloud-Init Logs

```bash
sudo tail -100 /var/log/cloud-init-output.log
```

Purpose:

* Troubleshoot bootstrap failures.
* Verify package installation.

---

# Minikube Cluster Creation

Minikube installation does not automatically create a cluster.

Initially:

```bash
minikube status
```

Output:

```text
Profile "minikube" not found
```

This is expected.

---

## Docker Permission Fix

```bash
sudo usermod -aG docker ubuntu
```

Apply group:

```bash
newgrp docker
```

Verify:

```bash
docker ps
```

---

## Create Minikube Cluster

```bash
minikube start --driver=docker
```

Verify:

```bash
minikube status
```

Expected:

```text
host: Running
kubelet: Running
apiserver: Running
```

---

## Verify Kubernetes

```bash
kubectl get nodes
```

Expected:

```text
minikube Ready
```

---

## Enable Metrics Server

```bash
minikube addons enable metrics-server
```

Verify:

```bash
kubectl get pods -n kube-system
```

---

## Create Project Namespaces

```bash
kubectl create namespace dev

kubectl create namespace argocd

kubectl create namespace monitoring
```

Verify:

```bash
kubectl get ns
```

Expected:

```text
default
kube-system
dev
argocd
monitoring
```
# PHASE 6 - APPLICATION DEPLOYMENT TO MINIKUBE

## Objective

In this phase we will:

1. Create a Flask application.
2. Create a Docker image.
3. Load the image into Minikube.
4. Create Kubernetes Deployment.
5. Create Kubernetes Service.
6. Verify application deployment.
7. Access the application.

---

# Architecture

GitHub Repository
│
▼
EC2 Instance
(Jenkins + Docker + Minikube)
│
▼
Docker Build
│
▼
Local Docker Image
│
▼
Minikube Image Store
│
▼
Kubernetes Deployment
│
▼
Kubernetes Service
│
▼
Browser

Note:
No Docker Hub and No AWS ECR are used in this project.

---

# Step 1: Create Application Directory

Location: VS Code

```bash
mkdir k8s-app
cd k8s-app
```

---

# Step 2: Create Flask Application

Create file:

app.py

```python
from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return "Welcome to CICD Terraform Project"

@app.route('/health')
def health():
    return "Application is Healthy"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

Explanation:

/ endpoint returns:

Welcome to CICD Terraform Project

/health endpoint returns:

Application is Healthy

---

# Step 3: Create requirements.txt

```text
flask==3.0.3
```

Explanation:

Docker installs Flask using this file.

---

# Step 4: Create Dockerfile

Create file:

Dockerfile

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python","app.py"]
```

Explanation:

FROM

* Downloads Python base image.

WORKDIR

* Creates /app directory.

COPY

* Copies files into container.

RUN

* Installs Flask.

EXPOSE

* Opens port 5000.

CMD

* Starts Flask application.

---

# Step 5: Push Code to GitHub

Location: VS Code

```bash
git add .
git commit -m "Added Flask Application"
git push
```

---

# Step 6: Clone Repository in EC2

Location: MobaXterm

```bash
cd ~

git clone https://github.com/<username>/CICD-Terraform.git

cd CICD-Terraform/k8s-app
```

Verify files:

```bash
ls
```

Expected:

```text
app.py
Dockerfile
requirements.txt
```

---

# Step 7: Build Docker Image

Location: MobaXterm

Verify Docker:

```bash
docker ps
```

Build image:

```bash
docker build -t flask-app:v1 .
```

Verify:

```bash
docker images
```

Expected:

```text
flask-app    v1
```

Explanation:

Docker reads the Dockerfile and creates a local image named:

flask-app:v1

---

# Step 8: Verify Minikube

```bash
minikube status
```

Expected:

```text
host: Running
kubelet: Running
apiserver: Running
```

Verify node:

```bash
kubectl get nodes
```

Expected:

```text
NAME       STATUS
minikube   Ready
```

---

# Step 9: Load Image into Minikube

```bash
minikube image load flask-app:v1
```

Verify:

```bash
minikube image ls
```

Expected:

```text
flask-app:v1
```

Explanation:

Image is copied from Docker into Minikube.

Since we are not using Docker Hub or ECR, Kubernetes can use this local image.

---

# Step 10: Create Namespace

```bash
kubectl create namespace dev
```

Verify:

```bash
kubectl get ns
```

Expected:

```text
default
kube-system
dev
argocd
monitoring
```

Explanation:

Namespace separates workloads logically.

---

# Step 11: Create Kubernetes Folder

```bash
mkdir k8s
```

---

# Step 12: Create Deployment Manifest

Create:

k8s/deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: flask-app
  namespace: dev

spec:
  replicas: 2

  selector:
    matchLabels:
      app: flask-app

  template:
    metadata:
      labels:
        app: flask-app

    spec:
      containers:
      - name: flask-app
        image: flask-app:v1
        imagePullPolicy: Never

        ports:
        - containerPort: 5000
```

Explanation:

Deployment creates:

* ReplicaSet
* 2 Pods

imagePullPolicy: Never

tells Kubernetes to use the local Minikube image instead of pulling from Docker Hub.

---

# Step 13: Create Service Manifest

Create:

k8s/service.yaml

```yaml
apiVersion: v1
kind: Service

metadata:
  name: flask-app-service
  namespace: dev

spec:
  selector:
    app: flask-app

  ports:
  - port: 80
    targetPort: 5000

  type: NodePort
```

Explanation:

Service provides a stable endpoint for Pods.

Traffic Flow:

User
↓
Service
↓
Pod 1

Pod 2

---

# Step 14: Deploy Application

```bash
kubectl apply -f k8s/deployment.yaml

kubectl apply -f k8s/service.yaml
```

Expected:

```text
deployment.apps/flask-app created

service/flask-app-service created
```

---

# Step 15: Verify Deployment

Check deployment:

```bash
kubectl get deployment -n dev
```

Expected:

```text
NAME        READY
flask-app   2/2
```

Check pods:

```bash
kubectl get pods -n dev
```

Expected:

```text
flask-app-xxxxx
flask-app-yyyyy
```

Status should be Running.

Check service:

```bash
kubectl get svc -n dev
```

Expected:

```text
flask-app-service
```

---

# Step 16: Access Application

Get URL:

```bash
minikube service flask-app-service -n dev --url
```

Example:

```text
http://192.168.49.2:30080
```

Test application:

```bash
curl $(minikube service flask-app-service -n dev --url)
```

Expected:

```text
Welcome to CICD Terraform Project
```

Health check:

```bash
curl $(minikube service flask-app-service -n dev --url)/health
```

Expected:

```text
Application is Healthy
```

---

# Validation Commands

```bash
docker images

minikube status

kubectl get nodes

kubectl get ns

kubectl get deployment -n dev

kubectl get pods -n dev

kubectl get svc -n dev
```

All commands should execute successfully before moving to Phase 7.

---




