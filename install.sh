#!/bin/bash
if [ "$(id -u)" -eq 0 ]; then
    echo "Do not run install.sh with sudo."
    echo "Run it as the ubuntu user: bash install.sh"
    exit 1
fi

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_DIR="$PROJECT_DIR/scripts"

LOG_DIR="$PROJECT_DIR/logs"
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "===================================================="
echo "      Complete DevOps Platform Installation"
echo "===================================================="
echo
echo "Started : $(date)"
echo "Logs    : $LOG_FILE"
echo

run_script() {

    SCRIPT_NAME=$1

    echo
    echo "===================================================="
    echo "Running : $SCRIPT_NAME"
    echo "===================================================="

    chmod +x "$SCRIPT_DIR/$SCRIPT_NAME"

    "$SCRIPT_DIR/$SCRIPT_NAME"

    echo
    echo "Completed : $SCRIPT_NAME"
}

run_script "01-os.sh"

run_script "02-docker.sh"

run_script "03-jenkins.sh"

run_script "04-kubernetes.sh"

run_script "05-helm.sh"

run_script "06-minikube.sh"

run_script "07-jenkins-config.sh"

run_script "08-plugins.sh"

run_script "09-argocd.sh"

run_script "10-monitoring.sh"

run_script "11-verify.sh"

echo
echo "===================================================="
echo "Installation Completed Successfully"
echo "===================================================="

echo

echo "Completed At : $(date)"

echo

echo "Log File :"

echo "$LOG_FILE"

echo

echo "Jenkins"

echo "http://$(curl -s http://checkip.amazonaws.com):8080"

echo

echo "Grafana"

echo "kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring --address=0.0.0.0"

echo

echo "ArgoCD"

echo "kubectl port-forward svc/argocd-server 8081:443 -n argocd --address=0.0.0.0"

echo

echo "Platform Ready."