#!/bin/bash

set -euo pipefail

echo "=========================================="
echo "      Docker Installation Started"
echo "=========================================="

# Remove old Docker packages
echo "[INFO] Removing old Docker packages..."

for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    sudo apt-get remove -y $pkg 2>/dev/null || true
done

echo "[INFO] Installing required dependencies..."

sudo apt-get update -y

sudo apt-get install -y \
ca-certificates \
curl \
gnupg

echo "[INFO] Adding Docker GPG Key..."

sudo install -m 0755 -d /etc/apt/keyrings

if [ ! -f /etc/apt/keyrings/docker.asc ]; then
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc
fi

sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "[INFO] Adding Docker Repository..."

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y

echo "[INFO] Installing Docker..."

sudo apt-get install -y \
docker-ce \
docker-ce-cli \
containerd.io \
docker-buildx-plugin \
docker-compose-plugin

echo "[INFO] Starting Docker..."

sudo systemctl enable docker

sudo systemctl restart docker

echo "[INFO] Adding Users to Docker Group..."

sudo usermod -aG docker ubuntu

if id "jenkins" &>/dev/null; then
    sudo usermod -aG docker jenkins
fi

echo "[INFO] Verifying Docker..."

docker --version

docker compose version

sudo docker run hello-world

echo "=========================================="
echo " Docker Installed Successfully"
echo "=========================================="