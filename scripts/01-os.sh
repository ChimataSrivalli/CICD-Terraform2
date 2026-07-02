#!/bin/bash

set -e

echo "========================================"
echo "Updating Ubuntu Packages"
echo "========================================"

sudo apt update -y
sudo apt upgrade -y

echo "========================================"
echo "Installing Required Packages"
echo "========================================"

sudo apt install -y \
curl \
wget \
git \
unzip \
zip \
jq \
vim \
tree \
apt-transport-https \
ca-certificates \
gnupg \
lsb-release \
software-properties-common

echo "========================================"
echo "Installing AWS CLI"
echo "========================================"

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip

unzip -o awscliv2.zip

sudo ./aws/install --update

rm -rf aws
rm awscliv2.zip

echo "========================================"
echo "Installed Versions"
echo "========================================"

git --version

curl --version | head -1

wget --version | head -1

aws --version

jq --version

tree --version

echo "========================================"
echo "OS Setup Completed Successfully"
echo "========================================"