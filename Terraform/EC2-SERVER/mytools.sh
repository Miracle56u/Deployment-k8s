#!/bin/bash

# Install AWS CLI
sudo yum update -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo yum install unzip -y
unzip awscliv2.zip
sudo ./aws/install

#Install Docker
sudo yum update -y
#Install prerequisites
sudo yum install -y ca-certificates curl
sudo mkdir -p /etc/yum.repos.d
#Dowload Docker's GPG key
sudo curl -fsSL https://download.docker.com/linux/centos/gpg -o /etc/pki/rpm-gpg/RPM-GPG-KEY-docker
sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-docker
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#Update packag list
sudo yum update -y
#Instal Docker components
sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo usermod -aG docker ec2-user
sudo chmod 777 /var/run/docker.sock
sudo systemctl start docker
sudo systemctl enable docker

#Install SonarQube
sudo yum update -y
sudo yum install java-17-amazon-corretto-devel -y
#Create Sonaqube user
sudo useradd sonar
#Download Sonarqube
cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.0.65466.zip
sudo unzip sonarqube-9.9.0.65466.zip
sudo mv sonarqube-9.9.0.65466 sonarqube
sudo chown -R sonar:sonar /opt/sonarqube
#Configure Sonarqube service
sudo tee /etc/systemd/system/sonarqube.service > /dev/null <<EOF
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF
#Start and enable sonarqube
sudo systemctl daemon-reload
sudo systemctl start sonarqube
sudo systemctl enable sonarqube
# Clean up
sudo rm -f /opt/sonarqube-9.9.0.65466.zip


# Update system
sudo yum update -y
# Add Trivy repository
sudo rpm --import https://aquasecurity.github.io/trivy-repo/rpm/public.key
echo -e '[trivy]\nname=Trivy repository\nbaseurl=https://aquasecurity.github.io/trivy-repo/rpm/releases/$basearch/\ngpgcheck=1\nenabled=1' | sudo tee -a /etc/yum.repos.d/trivy.repo
# Install Trivy
sudo yum install trivy -y


# Update system
sudo yum update -y
# Install Helm 
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
# Verify installation
helm version


# Update system
sudo yum update -y

# Install kubectl if not already installed
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Download ArgoCD CLI using official method
VERSION=$(curl -L -s https://raw.githubusercontent.com/argoproj/argo-cd/stable/VERSION)
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/v$VERSION/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD pods to be ready
kubectl wait --for=condition=ready pod --all -n argocd --timeout=300s


# Update system
sudo yum update -y

# Install Java (Jenkins requires Java)
sudo yum install java-17-amazon-corretto-devel -y

# Add Jenkins repository
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
sudo yum install jenkins -y

# Start and enable Jenkins service
sudo systemctl start jenkins
sudo systemctl enable jenkins


# Update system
sudo yum update -y

# Install Git
sudo yum install git -y


# Update system
sudo yum update -y

# Install yum-config-manager
sudo yum install -y yum-utils

# Add HashiCorp repository
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

# Install Terraform
sudo yum install terraform -y


# Update system
sudo yum update -y

# Download kubectl binary
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Clean up downloaded file
rm kubectl
