# CICD-Terraform
# to create ssh key
ssh-keygen -t rsa -b 4096
# To verify aws configuration
aws sts get-caller-identity

# To create s3 bucket
aws s3 mb s3://bucket_name

# To check bucket list
aws s3 ls

# To check the latest ami id without hardcoding
aws ssm get-parameter \
--name "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id" \
--region ap-south-1 \
--query "Parameter.Value" \
--output text

# Verify AMI Details
aws ec2 describe-images \
--image-ids ami-xxxxxxxxxxxxxxxxx \
--region ap-south-1

# to verift the key-pairs
aws ec2 describe-key-pairs


###### if jenkins fails to install use method 2
 # method 2(docker jenkins)

docker volume create jenkins_home

docker run -d \
--name jenkins \
--restart unless-stopped \
-p 8080:8080 \
-p 50000:50000 \
-v jenkins_home:/var/jenkins_home \
jenkins/jenkins:lts-jdk17

 # Verify Container Started
docker ps


#### for jenkins -must be java 21  version
# after terraform apply open linux in mobaxterm connect to the same ec2 instance then run these commands

sudo cloud-init status
java -version
docker version
git --version
sudo systemctl status jenkins
sudo systemctl status docker
kubectl version --client
heml version
minikube version
minikube status

--- in minikube status is minikube is not created yet so creating the minikube

sudo usermod -aG docker ubuntu
newgrp docker
docker ps
minikube start --driver=docker
minikube status
kubectl get nodes
minikube addons enable metrics-server
kubectl get pods -n kube-system
kubectl create namespace dev
kubectl create namespace argocd
kubectl create namespace monitoring
kubectl get ns

#adding the github webhook
webhook test




