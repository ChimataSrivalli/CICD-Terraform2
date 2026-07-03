#!/bin/bash

set -euo pipefail

echo "========================================="
echo "      Jenkins Docker Installation"
echo "========================================="

##############################################
# Install Java
##############################################

echo "[INFO] Installing Java 21..."

sudo apt update
sudo apt install -y openjdk-21-jdk

echo "[INFO] Java Version"

java -version

##############################################
# Check Docker
##############################################

echo "[INFO] Checking Docker..."

if ! systemctl is-active --quiet docker; then
    echo "[INFO] Starting Docker..."
    sudo systemctl start docker
fi

sudo systemctl enable docker

##############################################
# Remove Existing Jenkins Container
##############################################

if sudo docker ps -a --format '{{.Names}}' | grep -q "^jenkins$"; then
    echo "[INFO] Removing existing Jenkins container..."

    sudo docker stop jenkins || true
    sudo docker rm jenkins || true
fi

##############################################
# Create Jenkins Volume
##############################################

echo "[INFO] Creating Jenkins Volume..."

sudo docker volume create jenkins_home

##############################################
# Run Jenkins
##############################################

echo "[INFO] Starting Jenkins..."

sudo docker run -d \
    --name jenkins \
    --restart unless-stopped \
    -p 8080:8080 \
    -p 50000:50000 \
    -v jenkins_home:/var/jenkins_home \
    -v /var/run/docker.sock:/var/run/docker.sock \
    jenkins/jenkins:lts-jdk21

##############################################
# Wait for Jenkins
##############################################

echo "[INFO] Waiting for Jenkins to start..."

sleep 60

##############################################
# Jenkins Status
##############################################

echo
echo "========================================="
echo "Docker Containers"
echo "========================================="

sudo docker ps

##############################################
# Jenkins Version
##############################################

echo
echo "========================================="
echo "Jenkins Version"
echo "========================================="

sudo docker exec jenkins java -version || true

##############################################
# Initial Password
##############################################

echo
echo "========================================="
echo "Initial Admin Password"
echo "========================================="

sudo docker exec jenkins \
cat /var/jenkins_home/secrets/initialAdminPassword

##############################################
# Jenkins URL
##############################################

PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

echo
echo "========================================="
echo "Jenkins URL"
echo "========================================="

echo "http://$PUBLIC_IP:8080"

echo
echo "========================================="
echo "Jenkins Installed Successfully"
echo "========================================="