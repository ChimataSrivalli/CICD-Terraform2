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

-

