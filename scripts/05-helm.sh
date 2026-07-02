#!/bin/bash

set -euo pipefail

echo "========================================="
echo "        Helm Installation Started"
echo "========================================="

##############################################
# Update Packages
##############################################

echo "[INFO] Updating package list..."

sudo apt update -y

##############################################
# Download Helm Installation Script
##############################################

echo "[INFO] Downloading Helm..."

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

chmod 700 get_helm.sh

##############################################
# Install Helm
##############################################

echo "[INFO] Installing Helm..."

./get_helm.sh

##############################################
# Remove Installation Script
##############################################

rm -f get_helm.sh

##############################################
# Add Helm Repositories
##############################################

echo "[INFO] Adding Helm repositories..."

helm repo add stable https://charts.helm.sh/stable

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo add argo https://argoproj.github.io/argo-helm

##############################################
# Update Helm Repositories
##############################################

echo "[INFO] Updating Helm repositories..."

helm repo update

##############################################
# Verify Installation
##############################################

echo
echo "========================================="
echo "Installed Helm Version"
echo "========================================="

helm version

echo
echo "========================================="
echo "Configured Helm Repositories"
echo "========================================="

helm repo list

echo
echo "========================================="
echo "Helm Installation Completed Successfully"
echo "========================================="