#!/bin/bash

set -euo pipefail

echo "========================================="
echo "      Jenkins Installation Started"
echo "========================================="

echo "[INFO] Updating package index..."
sudo apt update -y

echo "[INFO] Installing Java 21..."
sudo apt install -y openjdk-21-jdk

echo "[INFO] Verifying Java..."
java -version

echo "[INFO] Installing Jenkins repository..."

sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | \
sudo tee /etc/apt/keyrings/jenkins-keyring.asc > /dev/null

echo \
"deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" | \
sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "[INFO] Updating package list..."
sudo apt update -y

echo "[INFO] Installing Jenkins..."
sudo apt install -y jenkins

echo "[INFO] Starting Jenkins..."
sudo systemctl enable jenkins
sudo systemctl restart jenkins

echo "[INFO] Waiting for Jenkins..."
sleep 20

echo
echo "========================================="
echo "Jenkins Service Status"
echo "========================================="

sudo systemctl status jenkins --no-pager

echo
echo "========================================="
echo "Installed Versions"
echo "========================================="

java -version

echo
jenkins --version || true

echo
echo "========================================="
echo "Initial Admin Password"
echo "========================================="

sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo
echo "========================================="
echo "Jenkins URL"
echo "========================================="

PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

echo "http://$PUBLIC_IP:8080"

echo
echo "========================================="
echo "Jenkins Installation Completed"
echo "========================================="