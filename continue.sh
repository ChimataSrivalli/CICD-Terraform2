#!/bin/bash

set -e

PROJECT_DIR=/home/ubuntu/CICD-Terraform2
SCRIPT_DIR=$PROJECT_DIR/scripts

LOG_DIR=$PROJECT_DIR/logs
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/continue.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "======================================"
echo " Continuing Installation"
echo "======================================"

cd "$PROJECT_DIR"

bash "$SCRIPT_DIR/03-jenkins.sh"

bash "$SCRIPT_DIR/04-kubernetes.sh"

bash "$SCRIPT_DIR/05-helm.sh"

bash "$SCRIPT_DIR/06-minikube.sh"

bash "$SCRIPT_DIR/07-jenkins-config.sh"

bash "$SCRIPT_DIR/08-plugins.sh"

bash "$SCRIPT_DIR/09-argocd.sh"

bash "$SCRIPT_DIR/10-monitoring.sh"

bash "$SCRIPT_DIR/11-verify.sh"

echo "======================================"
echo " Platform Installed Successfully"
echo "======================================"