#!/bin/bash

set -euo pipefail

echo "================================================="
echo "        DevOps Platform Verification"
echo "================================================="

PASS=0
FAIL=0

check_status() {
    if [ $? -eq 0 ]; then
        echo "✅ PASS"
        PASS=$((PASS+1))
    else
        echo "❌ FAIL"
        FAIL=$((FAIL+1))
    fi
}

########################################################
echo
echo "1. Checking Docker"
echo "--------------------------------------------------------"

systemctl is-active docker
check_status

########################################################
echo
echo "2. Checking Jenkins"
echo "--------------------------------------------------------"

systemctl is-active jenkins
check_status

########################################################
echo
echo "3. Checking Docker Version"
echo "--------------------------------------------------------"

docker --version
check_status

########################################################
echo
echo "4. Checking Terraform"
echo "--------------------------------------------------------"

terraform version
check_status

########################################################
echo
echo "5. Checking Kubectl"
echo "--------------------------------------------------------"

kubectl version --client
check_status

########################################################
echo
echo "6. Checking Helm"
echo "--------------------------------------------------------"

helm version
check_status

########################################################
echo
echo "7. Checking Minikube"
echo "--------------------------------------------------------"

minikube status
check_status

########################################################
echo
echo "8. Checking Kubernetes Nodes"
echo "--------------------------------------------------------"

kubectl get nodes
check_status

########################################################
echo
echo "9. Checking Kubernetes Namespaces"
echo "--------------------------------------------------------"

kubectl get ns
check_status

########################################################
echo
echo "10. Checking All Pods"
echo "--------------------------------------------------------"

kubectl get pods -A
check_status

########################################################
echo
echo "11. Checking ArgoCD Namespace"
echo "--------------------------------------------------------"

kubectl get ns argocd
check_status

########################################################
echo
echo "12. Checking ArgoCD Pods"
echo "--------------------------------------------------------"

kubectl get pods -n argocd
check_status

########################################################
echo
echo "13. Checking ArgoCD Service"
echo "--------------------------------------------------------"

kubectl get svc -n argocd
check_status

########################################################
echo
echo "14. Checking Monitoring Namespace"
echo "--------------------------------------------------------"

kubectl get ns monitoring
check_status

########################################################
echo
echo "15. Checking Monitoring Pods"
echo "--------------------------------------------------------"

kubectl get pods -n monitoring
check_status

########################################################
echo
echo "16. Checking Monitoring Services"
echo "--------------------------------------------------------"

kubectl get svc -n monitoring
check_status

########################################################
echo
echo "17. Checking Prometheus"
echo "--------------------------------------------------------"

kubectl get pods -n monitoring | grep prometheus
check_status

########################################################
echo
echo "18. Checking Grafana"
echo "--------------------------------------------------------"

kubectl get pods -n monitoring | grep grafana
check_status

########################################################
echo
echo "19. Checking Jenkins Kubernetes Access"
echo "--------------------------------------------------------"

sudo -u jenkins bash <<EOF
export KUBECONFIG=/var/lib/jenkins/.kube/config
kubectl get nodes
EOF

check_status

########################################################
echo
echo "20. Checking Minikube IP"
echo "--------------------------------------------------------"

minikube ip
check_status

########################################################
echo
echo "21. Checking Disk Usage"
echo "--------------------------------------------------------"

df -h
check_status

########################################################
echo
echo "22. Checking Memory Usage"
echo "--------------------------------------------------------"

free -h
check_status

########################################################
echo
echo "23. Checking Running Containers"
echo "--------------------------------------------------------"

docker ps
check_status

########################################################
echo
echo "24. Checking Cluster Info"
echo "--------------------------------------------------------"

kubectl cluster-info
check_status

########################################################
echo
echo "25. Checking Helm Releases"
echo "--------------------------------------------------------"

helm list -A
check_status

########################################################

echo
echo "================================================="
echo "Verification Summary"
echo "================================================="

echo

echo "Passed : $PASS"

echo "Failed : $FAIL"

echo

if [ $FAIL -eq 0 ]; then

echo "🎉 Congratulations!"

echo "Complete DevOps Platform Installed Successfully."

else

echo "Some checks failed."

echo "Please review the failed components."

fi

echo
echo "================================================="