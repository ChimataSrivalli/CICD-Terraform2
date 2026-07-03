#!/bin/bash

set -euo pipefail

echo "=========================================="
echo "      Docker Installation Started"
echo "=========================================="

#########################################
# Remove old Docker packages
#########################################

echo "[INFO] Removing old Docker packages..."

for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    sudo apt-get remove -y "$pkg" 2>/dev/null || true
done

#########################################
# Install dependencies
#########################################

echo "[INFO] Installing required dependencies..."

sudo apt-get update -y

sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg

#########################################
# Add Docker GPG Key
#########################################

echo "[INFO] Adding Docker GPG Key..."

sudo install -m 0755 -d /etc/apt/keyrings

if [ ! -f /etc/apt/keyrings/docker.asc ]; then
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        -o /etc/apt/keyrings/docker.asc
fi

sudo chmod a+r /etc/apt/keyrings/docker.asc

#########################################
# Add Docker Repository
#########################################

echo "[INFO] Adding Docker Repository..."

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt-get update -y

#########################################
# Install Docker
#########################################

echo "[INFO] Installing Docker..."

sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

#########################################
# Enable Docker
#########################################

echo "[INFO] Starting Docker..."

sudo systemctl enable docker
sudo systemctl restart docker

#########################################
# Docker Group
#########################################

echo "[INFO] Adding users to Docker group..."

sudo groupadd docker 2>/dev/null || true

sudo usermod -aG docker ubuntu

if id "jenkins" &>/dev/null; then
    sudo usermod -aG docker jenkins
fi

#########################################
# Verify Installation
#########################################

echo "[INFO] Docker Version"

sudo docker --version

echo
echo "[INFO] Docker Compose Version"

sudo docker compose version

echo
echo "[INFO] Running Hello World"

sudo docker run --rm hello-world

#########################################
# Install Continue Service
#########################################

echo "[INFO] Installing continue.service..."

sudo cp /home/ubuntu/CICD-Terraform2/continue.service \
/etc/systemd/system/continue.service

sudo chmod 644 /etc/systemd/system/continue.service

sudo systemctl daemon-reload

sudo systemctl enable continue.service

#########################################
# Reboot
#########################################

echo
echo "=========================================="
echo " Docker Installed Successfully"
echo "=========================================="

echo
echo "[INFO] Docker group changes require a reboot."

echo "[INFO] System will reboot in 10 seconds..."

sleep 10

sudo reboot