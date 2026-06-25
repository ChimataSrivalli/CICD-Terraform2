#!/bin/bash

# Update OS
apt update -y
apt upgrade -y

# Install Java
sudo apt install openjdk-21-jdk -y

# Install Git
apt install -y git

# Install curl and gnupg
apt install -y curl wget gnupg software-properties-common

# Install Docker
apt install -y docker.io

systemctl enable docker
systemctl start docker

# Allow ubuntu user to use docker
usermod -aG docker ubuntu

# -------------------------
# Jenkins Installation
# -------------------------

apt install -y gnupg curl

gpg --keyserver keyserver.ubuntu.com \
    --recv-keys 7198F4B714ABFC68

gpg --export 7198F4B714ABFC68 | \
tee /etc/apt/trusted.gpg.d/jenkins.gpg >/dev/null

echo "deb https://pkg.jenkins.io/debian-stable binary/" \
> /etc/apt/sources.list.d/jenkins.list

apt update -y

apt install -y jenkins

systemctl enable jenkins
systemctl start jenkins

# -------------------------
# Kubectl Installation
# -------------------------

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

rm -f kubectl

# -------------------------
# Helm Installation
# -------------------------

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# -------------------------
# Minikube Installation
# -------------------------

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

install minikube-linux-amd64 /usr/local/bin/minikube

rm -f minikube-linux-amd64

# -------------------------
# Versions Verification
# -------------------------

java -version
git --version
docker --version
kubectl version --client
helm version
minikube version

echo "Bootstrap Completed Successfully"