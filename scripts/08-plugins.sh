#!/bin/bash

set -euo pipefail

echo "=========================================="
echo "     Jenkins Plugin Installation"
echo "=========================================="

JENKINS_URL="http://localhost:8080"

#############################################
# Check Jenkins
#############################################

echo "[INFO] Checking Jenkins..."

if ! systemctl is-active --quiet jenkins; then
    echo "[ERROR] Jenkins is not running."
    exit 1
fi

#############################################
# Check CLI
#############################################

if [ ! -f /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar ]; then
    echo "[INFO] Downloading Jenkins CLI..."

    wget ${JENKINS_URL}/jnlpJars/jenkins-cli.jar \
    -O ~/jenkins-cli.jar

else

    cp /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar ~/jenkins-cli.jar

fi

#############################################
# Plugin List
#############################################

PLUGINS=(
git
github
workflow-aggregator
pipeline-stage-view
docker-plugin
docker-workflow
kubernetes-cli
credentials
credentials-binding
ssh-agent
ssh-slaves
blueocean
terraform
ansicolor
timestamper
matrix-auth
configuration-as-code
)

#############################################
# Install Plugins
#############################################

echo
echo "=========================================="
echo "Installing Plugins"
echo "=========================================="

for plugin in "${PLUGINS[@]}"
do

echo "Installing $plugin"

java -jar ~/jenkins-cli.jar \
-s ${JENKINS_URL} \
-auth admin:YOUR_JENKINS_PASSWORD \
install-plugin $plugin

done

#############################################
# Restart Jenkins
#############################################

echo
echo "Restarting Jenkins..."

java -jar ~/jenkins-cli.jar \
-s ${JENKINS_URL} \
-auth admin:YOUR_JENKINS_PASSWORD \
safe-restart

echo
echo "=========================================="
echo "Plugin Installation Completed"
echo "=========================================="