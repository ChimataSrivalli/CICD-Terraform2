#!/bin/bash

set -euo pipefail

echo "==========================================="
echo " Jenkins Kubernetes Configuration Started"
echo "==========================================="

#############################################
# Check Jenkins Installation
#############################################

if ! id jenkins &>/dev/null; then
    echo "[ERROR] Jenkins user not found."
    exit 1
fi

#############################################
# Check Minikube
#############################################

if ! minikube status >/dev/null 2>&1; then
    echo "[ERROR] Minikube is not running."
    exit 1
fi

#############################################
# Create Jenkins Directories
#############################################

echo "[INFO] Creating Jenkins Kubernetes directories..."

sudo mkdir -p /var/lib/jenkins/.kube
sudo mkdir -p /var/lib/jenkins/.minikube

#############################################
# Copy kubeconfig
#############################################

echo "[INFO] Copying kubeconfig..."

sudo cp /home/ubuntu/.kube/config \
/var/lib/jenkins/.kube/config

#############################################
# Copy Minikube Certificates
#############################################

echo "[INFO] Copying Minikube certificates..."

sudo cp -r /home/ubuntu/.minikube/* \
/var/lib/jenkins/.minikube/

#############################################
# Replace Paths
#############################################

echo "[INFO] Updating kubeconfig..."

sudo sed -i \
's|/home/ubuntu/.minikube|/var/lib/jenkins/.minikube|g' \
/var/lib/jenkins/.kube/config

#############################################
# Change Ownership
#############################################

echo "[INFO] Setting permissions..."

sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube

sudo chown -R jenkins:jenkins /var/lib/jenkins/.minikube

#############################################
# Restart Jenkins
#############################################

echo "[INFO] Restarting Jenkins..."

sudo systemctl restart jenkins

sleep 15

#############################################
# Verify Jenkins
#############################################

echo

echo "==========================================="
echo " Jenkins Status"
echo "==========================================="

sudo systemctl status jenkins --no-pager

#############################################
# Verify Kubernetes as Jenkins User
#############################################

echo

echo "==========================================="
echo " Kubernetes Access Test"
echo "==========================================="

sudo -u jenkins bash <<EOF

export KUBECONFIG=/var/lib/jenkins/.kube/config

kubectl get nodes

echo

kubectl cluster-info

EOF

echo

echo "==========================================="
echo " Jenkins Kubernetes Configuration Complete"
echo "==========================================="