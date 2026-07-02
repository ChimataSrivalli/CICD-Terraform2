#!/bin/bash

set -euo pipefail

echo "========================================="
echo " Kubernetes Tools Installation Started"
echo "========================================="

##############################################
# Update Packages
##############################################

echo "[INFO] Updating Ubuntu..."

sudo apt update -y

##############################################
# Install Terraform
##############################################

echo "[INFO] Installing Terraform..."

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com \
$(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update -y

sudo apt install terraform -y

##############################################
# Install kubectl
##############################################

echo "[INFO] Installing kubectl..."

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

chmod +x kubectl

sudo mv kubectl /usr/local/bin/

##############################################
# Install Minikube
##############################################

echo "[INFO] Installing Minikube..."

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

sudo install minikube-linux-amd64 /usr/local/bin/minikube

rm minikube-linux-amd64

##############################################
# Verify Installations
##############################################

echo
echo "========================================="
echo " Installed Versions"
echo "========================================="

echo
terraform version

echo
kubectl version --client

echo
minikube version

echo
docker --version

echo
java -version

echo
echo "========================================="
echo " Kubernetes Tools Installed Successfully"
echo "========================================="