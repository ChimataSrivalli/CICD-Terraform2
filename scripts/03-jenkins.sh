#!/bin/bash

set -euo pipefail

echo "========================================="
echo "      Jenkins Installation Started"
echo "========================================="


##############################################
# Update Packages
##############################################

echo "[INFO] Updating package index..."

sudo apt update

##############################################
# Install Required Packages
##############################################

echo "[INFO] Installing Required Packages..."

sudo apt install -y \
    curl \
    wget \
    gnupg \
    ca-certificates \
    software-properties-common

##############################################
# Install Java 21
##############################################

echo "[INFO] Installing Java 21..."

sudo apt install -y openjdk-21-jdk

echo "[INFO] Java Version"

java -version

##############################################
# Remove Old Jenkins Repository (if any)
##############################################

echo "[INFO] Cleaning old Jenkins repository..."

sudo rm -f /etc/apt/sources.list.d/jenkins.list
sudo rm -f /usr/share/keyrings/jenkins-keyring.asc
sudo rm -f /etc/apt/trusted.gpg.d/jenkins.gpg

echo "[INFO] Cleaning apt cache..."

sudo apt clean
sudo rm -rf /var/lib/apt/lists/*


##############################################
# Add Jenkins Repository
##############################################

echo "[INFO] Adding Jenkins Repository..."

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | \
sudo tee /usr/share/keyrings/jenkins-keyring.asc >/dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
sudo tee /etc/apt/sources.list.d/jenkins.list >/dev/null

##############################################
# Update Repository
##############################################

echo "[INFO] Updating package index..."

sudo apt update

##############################################
# Install Jenkins
##############################################

echo "[INFO] Installing Jenkins..."

sudo apt install -y jenkins

##############################################
# Enable Jenkins
##############################################

echo "[INFO] Starting Jenkins..."

sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl restart jenkins

echo "[INFO] Waiting for Jenkins..."

sleep 20

##############################################
# Status
##############################################

echo
echo "========================================="
echo "Jenkins Status"
echo "========================================="

sudo systemctl --no-pager status jenkins

##############################################
# Versions
##############################################

echo
echo "========================================="
echo "Installed Versions"
echo "========================================="

java -version

echo

jenkins --version || true


##############################################
# Jenkins URL
##############################################

PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

echo
echo "========================================="
echo "Jenkins URL"
echo "========================================="

echo "http://${PUBLIC_IP}:8080"

echo
echo "========================================="
echo "Initial Admin Password"
echo "========================================="

sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo
echo "========================================="
echo "Jenkins Installation Completed"
echo "========================================="