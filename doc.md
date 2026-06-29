# Terraform + Jenkins + Minikube CI/CD Project

## Phase 1 to Phase 8 Documentation


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

# Phase 7 – Jenkins CI/CD Pipeline with Kubernetes (Minikube)

## Objective

In this phase, Jenkins is integrated with GitHub and Kubernetes (Minikube). Jenkins automatically pulls the application code from GitHub, builds the Docker image, loads it into Minikube, and deploys the application into the Kubernetes cluster.

---

# Step 1: Verify Jenkins

Open Jenkins in the browser.

```
http://<EC2-Public-IP>:8080
```

Login using the admin credentials.

Verify Jenkins is running correctly before creating the pipeline.

---

# Step 2: Install Required Plugins

Navigate to

```
Manage Jenkins
→ Plugins
```

Install:

* Pipeline
* Git
* Docker Pipeline
* Kubernetes CLI

Restart Jenkins if prompted.

---

# Step 3: Configure GitHub Access

Generate an SSH key on the EC2 instance.

```
ssh-keygen -t rsa -b 4096
```

Display the public key.

```
cat ~/.ssh/id_rsa.pub
```

Copy the output.

Go to GitHub

```
Settings
→ SSH and GPG Keys
→ New SSH Key
```

Paste the key.

---

Change the repository remote to SSH.

```
git remote set-url origin git@github.com:ChimataSrivalli/CICD-Terraform.git
```

Verify.

```
git remote -v
```

Expected output:

```
origin git@github.com:ChimataSrivalli/CICD-Terraform.git
```

Test GitHub authentication.

```
ssh -T git@github.com
```

Expected:

```
Hi ChimataSrivalli!
You've successfully authenticated.
```

---

# Step 4: Create the Jenkinsfile

Create the Jenkinsfile in the root of the repository.

```
nano Jenkinsfile
```

Paste the pipeline code.

Commit it.

```
git add Jenkinsfile
git commit -m "Added Jenkins Pipeline"
git push origin main
```

---

# Step 5: Create Jenkins Pipeline Job

Create a new Jenkins Item.

Choose:

```
Pipeline
```

Pipeline Definition:

```
Pipeline script from SCM
```

SCM:

```
Git
```

Repository URL:

```
git@github.com:ChimataSrivalli/CICD-Terraform.git
```

Branch:

```
*/main
```

Script Path:

```
Jenkinsfile
```

Save.

---

# Step 6: Build the Docker Image

The Jenkins pipeline builds the Docker image.

```
docker build -t flask-app:v1 .
```

Verify.

```
docker images
```

---

# Step 7: Load the Image into Minikube

Since Docker Hub/ECR is not used in this project, load the image directly into Minikube.

```
minikube image load flask-app:v1
```

Verify.

```
minikube image ls
```

---

# Step 8: Deploy to Kubernetes

Deploy the manifests.

```
kubectl apply -f k8s/deployment.yaml

kubectl apply -f k8s/service.yaml
```

Verify.

```
kubectl get pods -n dev

kubectl get deployment -n dev

kubectl get svc -n dev
```

---

# Step 9: Configure Jenkins Access to Minikube (One-Time Setup)

During the project, Jenkins could not access the Kubernetes cluster because the Minikube certificates were stored inside:

```
/home/ubuntu/.minikube
```

The Jenkins user does not have permission to access the Ubuntu user's home directory.

The following one-time setup fixes the problem.

---

## Step 1: Exit from the Jenkins user

```
exit
```

Verify the current user.

```
whoami
```

Expected output:

```
ubuntu
```

---

## Step 2: Create the Jenkins Minikube directory

```
sudo mkdir -p /var/lib/jenkins/.minikube
```

---

## Step 3: Copy the Minikube certificates

```
sudo cp -r /home/ubuntu/.minikube/* /var/lib/jenkins/.minikube/
```

---

## Step 4: Change ownership

```
sudo chown -R jenkins:jenkins /var/lib/jenkins/.minikube
```

---

## Step 5: Create the Jenkins kube directory

```
sudo mkdir -p /var/lib/jenkins/.kube
```

---

## Step 6: Copy the kubeconfig

```
sudo cp /home/ubuntu/.kube/config /var/lib/jenkins/.kube/config
```

---

## Step 7: Change ownership

```
sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube
```

---

## Step 8: Edit the kubeconfig

Open:

```
sudo nano /var/lib/jenkins/.kube/config
```

Replace every occurrence of

```
/home/ubuntu/.minikube
```

with

```
/var/lib/jenkins/.minikube
```

The file should contain:

```
certificate-authority: /var/lib/jenkins/.minikube/ca.crt

client-certificate: /var/lib/jenkins/.minikube/profiles/minikube/client.crt

client-key: /var/lib/jenkins/.minikube/profiles/minikube/client.key
```

Save:

```
Ctrl + O
Enter
Ctrl + X
```

---

## Step 9: Restart Jenkins

```
sudo systemctl restart jenkins
```

---

## Step 10: Test as the Jenkins user

```
sudo su - jenkins

export KUBECONFIG=/var/lib/jenkins/.kube/config

kubectl get nodes
```

Expected output:

```
NAME        STATUS   ROLES           AGE   VERSION

minikube    Ready    control-plane   ...   ...
```

This confirms Jenkins can communicate with the Kubernetes cluster.

---

# Step 10: Run the Jenkins Pipeline

Click:

```
Build Now
```

Open:

```
Console Output
```

Expected pipeline stages:

```
Checkout

Build Docker Image

Load Image into Minikube

Deploy to Kubernetes

Success
```

---

# Step 11: Verify the Deployment

Check the deployment.

```
kubectl get deployment -n dev
```

Check the pods.

```
kubectl get pods -n dev
```

Check the service.

```
kubectl get svc -n dev
```

Open the application.

```
minikube service flask-service -n dev
```

or

```
kubectl port-forward svc/flask-service 5000:5000 -n dev
```

Open:

```
http://<EC2-Public-IP>:5000
```

or

```
http://localhost:5000
```

depending on the chosen access method.

---

# Common Issues Encountered During Phase 7

### 1. Jenkins failed to start

Cause:

```
Java 17 installed
```

Jenkins version required:

```
Java 21
```

Solution:

Install OpenJDK 21 and restart Jenkins.

---

### 2. Kubernetes Pods in ErrImageNeverPull

Cause:

Docker image was not available inside Minikube.

Solution:

```
docker build -t flask-app:v1 .

minikube image load flask-app:v1
```

---

### 3. Jenkins Authentication Required

Error:

```
Authentication required

Forbidden
```

Cause:

The Jenkins user could not access the Ubuntu user's Minikube certificates.

Solution:

Copy the Minikube configuration into:

```
/var/lib/jenkins/.minikube

/var/lib/jenkins/.kube
```

Update the paths inside:

```
/var/lib/jenkins/.kube/config
```

---

### 4. Git Push Failed

Error:

```
Password authentication is not supported.
```

Solution:

Configure GitHub SSH authentication.

```
ssh-keygen

Add the public key to GitHub

Change the remote URL to SSH

git push origin main
```

---

### 5. Jenkins Build Waiting Forever

Console Output:

```
Still waiting to schedule task

Waiting for next available executor
```

Cause:

The Jenkins controller node was temporarily unavailable or had exhausted disk space.

Solution:

Verify the Built-In Node is online.

Check available disk space:

```
df -h
```

Free space if required or increase the EC2 root volume, then restart Jenkins.

---

# Phase 7 Completed

At the end of this phase, Jenkins successfully:

* Pulled source code from GitHub.
* Built the Docker image.
* Loaded the image into Minikube.
* Connected securely to the Kubernetes cluster.
* Deployed the application into the `dev` namespace.
* Automated the complete CI pipeline without using Docker Hub or Amazon ECR.

<<<<<<< HEAD

=======
# PHASE 8 – Continuous Integration (CI) with Jenkins

## Objective

The objective of this phase is to automate the Continuous Integration (CI) process using Jenkins. Whenever code is pushed to the GitHub repository, Jenkins automatically detects the changes, checks out the latest code, builds a Docker image, loads the image into Minikube, deploys the application to Kubernetes, and verifies that the updated application is running successfully.

---

# Architecture

```
Developer
      │
      ▼
Modify Application
      │
      ▼
git add
git commit
git push
      │
      ▼
GitHub Repository
      │
      ▼
GitHub Webhook
      │
      ▼
Jenkins Pipeline
      │
      ├── Checkout Source Code
      ├── Build Docker Image
      ├── Load Image into Minikube
      ├── Deploy to Kubernetes
      └── Verify Deployment
      │
      ▼
Kubernetes (Minikube)
      │
      ▼
Updated Flask Application
```

---

# Prerequisites

Before starting Phase 8, ensure the following services are running successfully.

## Verify Jenkins

```bash
sudo systemctl status jenkins
```

Expected Output

```
Active: active (running)
```

---

## Verify Docker

```bash
sudo systemctl status docker
```

Expected Output

```
Active: active (running)
```

---

## Verify Minikube

```bash
minikube status
```

Expected Output

```
minikube: Running
kubelet: Running
apiserver: Running
```

---

## Verify Kubernetes Cluster

```bash
kubectl get nodes
```

Expected Output

```
NAME        STATUS   ROLES
minikube    Ready    control-plane
```

---

# Step 1 – Open the Project

Connect to the EC2 instance.

Navigate to the project directory.

```bash
cd ~/CICD-Terraform
```

Verify the project structure.

```bash
ls
```

Example Output

```
Jenkinsfile
README.md
terraform
k8s-app
```

---

# Step 2 – Modify the Application

Navigate to the application directory.

```bash
cd k8s-app
```

Open the Flask application.

```bash
nano app.py
```

Example

Before

```python
return "Hello from Flask!"
```

After

```python
return "Hello from Jenkins CI/CD Pipeline!"
```

Save the file.

```
Ctrl + O

Enter

Ctrl + X
```

---

# Step 3 – Verify Changes

Check Git status.

```bash
git status
```

Expected Output

```
modified: k8s-app/app.py
```

---

# Step 4 – Commit the Changes

Stage all changes.

```bash
git add .
```

Commit them.

```bash
git commit -m "Updated Flask application"
```

Expected Output

```
1 file changed
```

---

# Step 5 – Configure Git Identity (Only Once)

If Git displays

```
Author identity unknown
```

Configure your Git username.

```bash
git config --global user.name "ChimataSrivalli"
```

Configure your email.

```bash
git config --global user.email "your-email@example.com"
```

Verify.

```bash
git config --list
```

---

# Step 6 – GitHub Authentication

GitHub no longer supports password authentication for Git operations.

If you receive

```
Invalid username or token

Password authentication is not supported
```

Do not enter your GitHub password.

Instead, configure SSH authentication.

---

# Step 7 – Generate an SSH Key (One-Time Setup)

Check whether an SSH key already exists.

```bash
ls -la ~/.ssh
```

If the following files exist, skip key generation.

```
id_rsa
id_rsa.pub
```

Otherwise generate a new key.

```bash
ssh-keygen -t rsa -b 4096
```

Press Enter for every prompt.

---

# Step 8 – Add the SSH Key to GitHub

Display the public key.

```bash
cat ~/.ssh/id_rsa.pub
```

Copy the complete key.

Open GitHub.

Navigate to

```
Profile

↓

Settings

↓

SSH and GPG Keys

↓

New SSH Key
```

Title

```
EC2
```

Paste the copied public key.

Click

```
Add SSH Key
```

---

# Step 9 – Test SSH Authentication

Test the SSH connection.

```bash
ssh -T git@github.com
```

If prompted

```
Are you sure you want to continue connecting?
```

Type

```
yes
```

Expected Output

```
Hi ChimataSrivalli!

You've successfully authenticated.
```

If you receive

```
Permission denied (publickey)
```

The SSH key has not been added correctly.

Verify the SSH key on GitHub and repeat the test.

---

# Step 10 – Change the Git Remote to SSH

Check the current remote.

```bash
git remote -v
```

If it displays

```
https://github.com/ChimataSrivalli/CICD-Terraform.git
```

Remove it.

```bash
git remote remove origin
```

Add the SSH remote.

```bash
git remote add origin git@github.com:ChimataSrivalli/CICD-Terraform.git
```

Verify.

```bash
git remote -v
```

Expected Output

```
origin git@github.com:ChimataSrivalli/CICD-Terraform.git
```

---

# Step 11 – Push the Code

Push the latest commit.

```bash
git push origin main
```

Expected Output

```
Enumerating objects...

Writing objects...

Done
```

No GitHub username or password should be requested.

---

# Step 12 – Verify GitHub Repository

Open the GitHub repository.

Verify that:

* Latest commit is visible.
* Modified application code is present.
* Jenkinsfile exists.
* README.md is updated (if modified).

---

# Step 13 – Trigger Jenkins

If GitHub Webhook is configured, Jenkins starts automatically after every push.

Otherwise

Open Jenkins.

```
Dashboard

↓

Pipeline

↓

Build Now
```

---

# Step 14 – Monitor the Build

Open

```
Dashboard

↓

Build History

↓

Latest Build

↓

Console Output
```

The pipeline should execute the following stages.

```
Checkout Source Code

↓

Build Docker Image

↓

Load Image into Minikube

↓

Deploy Application

↓

Verify Deployment
```

Final Output

```
Finished: SUCCESS
```

---

# Step 15 – Verify Kubernetes

Check the deployment.

```bash
kubectl get deployment -n dev
```

Expected

```
READY

2/2
```

Check the pods.

```bash
kubectl get pods -n dev
```

Expected

```
STATUS

Running
```

---

# Step 16 – Access the Application

Retrieve the service URL.

```bash
minikube service flask-service -n dev --url
```

Example

```
http://127.0.0.1:43251
```

Open the URL in a browser.

The updated Flask application should be displayed.

---

# Commands Used

```bash
cd ~/CICD-Terraform

cd k8s-app

nano app.py

git status

git add .

git commit -m "Updated Flask application"

git config --global user.name "ChimataSrivalli"

git config --global user.email "your-email@example.com"

ls -la ~/.ssh

ssh-keygen -t rsa -b 4096

cat ~/.ssh/id_rsa.pub

ssh -T git@github.com

git remote -v

git remote remove origin

git remote add origin git@github.com:ChimataSrivalli/CICD-Terraform.git

git push origin main

kubectl get pods -n dev

kubectl get deployment -n dev

minikube service flask-service -n dev --url
```

---

# Troubleshooting

## Problem

```
Password authentication is not supported
```

### Solution

Use SSH authentication instead of HTTPS.

---

## Problem

```
Permission denied (publickey)
```

### Solution

* Verify that the public SSH key has been added to GitHub.
* Test using:

```bash
ssh -T git@github.com
```

---

## Problem

```
nothing to commit, working tree clean
```

### Solution

No files have changed. Modify a project file (such as `app.py` or `README.md`) before committing.

---

## Problem

Jenkins build does not start automatically.

### Solution

* Verify the GitHub webhook configuration.
* If needed, start the build manually using **Build Now** in Jenkins.

---

# Phase 8 Summary

In this phase, Jenkins was integrated with GitHub to automate the Continuous Integration (CI) workflow. The project was configured to use SSH-based Git authentication, allowing secure communication with GitHub without passwords. Application changes were committed and pushed to the repository, triggering Jenkins to build the Docker image, load it into Minikube, deploy it to Kubernetes, and verify that the updated application was running successfully. This completed the CI portion of the project and prepared the environment for the Continuous Deployment (CD) phase using Argo CD.
>>>>>>> 629c9b9 (readme)


