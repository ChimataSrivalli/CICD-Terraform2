#!/bin/bash

set -euo pipefail

echo "========================================="
echo " Prometheus + Grafana Installation"
echo "========================================="

#############################################
# Check Kubernetes Cluster
#############################################

echo "[INFO] Checking Kubernetes Cluster..."

kubectl get nodes

#############################################
# Add Helm Repository
#############################################

echo "[INFO] Adding Prometheus Helm Repository..."

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true

helm repo update

#############################################
# Create Namespace
#############################################

echo "[INFO] Creating Monitoring Namespace..."

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

#############################################
# Install kube-prometheus-stack
#############################################

echo "[INFO] Installing Prometheus & Grafana..."

helm upgrade --install monitoring \
prometheus-community/kube-prometheus-stack \
--namespace monitoring

#############################################
# Wait for Deployments
#############################################

echo
echo "[INFO] Waiting for Monitoring Pods..."

kubectl wait \
--for=condition=Ready \
pods \
--all \
-n monitoring \
--timeout=600s

#############################################
# Expose Grafana
#############################################

echo
echo "[INFO] Changing Grafana Service to NodePort..."

kubectl patch svc monitoring-grafana \
-n monitoring \
-p '{"spec":{"type":"NodePort"}}'

sleep 10

#############################################
# Get NodePort
#############################################

GRAFANA_PORT=$(kubectl get svc monitoring-grafana \
-n monitoring \
-o jsonpath='{.spec.ports[0].nodePort}')

#############################################
# Get Minikube IP
#############################################

MINIKUBE_IP=$(minikube ip)

#############################################
# Get EC2 Public IP
#############################################

PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

#############################################
# Get Grafana Password
#############################################

echo
echo "========================================="
echo " Grafana Credentials"
echo "========================================="

echo "Username : admin"

echo -n "Password : "

kubectl get secret \
-n monitoring \
monitoring-grafana \
-o jsonpath="{.data.admin-password}" | base64 -d

echo

#############################################
# Display URLs
#############################################

echo
echo "========================================="
echo " Grafana URL"
echo "========================================="

echo

echo "Minikube"

echo

echo "http://${MINIKUBE_IP}:${GRAFANA_PORT}"

echo

echo "EC2"

echo

echo "http://${PUBLIC_IP}:${GRAFANA_PORT}"

echo

#############################################
# Verify
#############################################

echo
echo "========================================="
echo " Monitoring Pods"
echo "========================================="

kubectl get pods -n monitoring

echo

echo "========================================="
echo " Monitoring Services"
echo "========================================="

kubectl get svc -n monitoring

echo

echo "========================================="
echo " Prometheus"
echo "========================================="

kubectl get pods -n monitoring | grep prometheus

echo

echo "========================================="
echo " Grafana"
echo "========================================="

kubectl get pods -n monitoring | grep grafana

echo

echo "========================================="
echo " Installation Completed"
echo "========================================="