#!/bin/bash

set -euo pipefail

echo "========================================="
echo "      Minikube Cluster Setup Started"
echo "========================================="

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
# Delete Existing Cluster (Optional)
##############################################

if minikube status >/dev/null 2>&1; then
    echo "[INFO] Existing Minikube cluster found."
    echo "[INFO] Skipping cluster deletion."
fi

##############################################
# Start Minikube
##############################################

echo "[INFO] Starting Minikube..."

minikube start \
    --driver=docker \
    --cpus=2 \
    --memory=4096 \
    --disk-size=20g \
    --kubernetes-version=stable

##############################################
# Enable Addons
##############################################

echo "[INFO] Enabling Metrics Server..."

minikube addons enable metrics-server

echo "[INFO] Enabling Dashboard..."

minikube addons enable dashboard

echo "[INFO] Enabling Default Storage..."

minikube addons enable default-storageclass

minikube addons enable storage-provisioner

##############################################
# Wait for Node
##############################################

echo "[INFO] Waiting for Kubernetes Node..."

kubectl wait \
--for=condition=Ready node/minikube \
--timeout=300s

##############################################
# Cluster Information
##############################################

echo

echo "========================================="
echo "Cluster Information"
echo "========================================="

kubectl cluster-info

echo

echo "========================================="
echo "Minikube Status"
echo "========================================="

minikube status

echo

echo "========================================="
echo "Nodes"
echo "========================================="

kubectl get nodes -o wide

echo

echo "========================================="
echo "Namespaces"
echo "========================================="

kubectl get ns

echo

echo "========================================="
echo "System Pods"
echo "========================================="

kubectl get pods -A

echo

echo "========================================="
echo "Minikube IP"
echo "========================================="

minikube ip

echo

echo "========================================="
echo "Minikube Setup Completed Successfully"
echo "========================================="