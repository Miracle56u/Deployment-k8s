!/bin/bash

# Install AWS CLI
sudo apt install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install Docker
# Add Docker's official GPG key:
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
# timeout 60 
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo usermod -aG docker ubuntu
sudo chmod 777 /var/run/docker.sock
# sudo newgrp docker
docker --version

# Install Sonarqube (as image)
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community

# Install Trivy
sudo apt-get install -y wget apt-transport-https gnupg
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update -y
sudo apt-get install trivy -y

# Install Helm
# Ref: https://helm.sh/docs/intro/install/
# Ref (for .tar.gz file): https://github.com/helm/helm/releases
"wget https://get.helm.sh/helm-v3.16.1-linux-amd64.tar.gz",
"tar -zxvf helm-v3.16.1-linux-amd64.tar.gz",
"sudo mv linux-amd64/helm /usr/local/bin/helm",
"helm version",

# Install ArgoCD
# Ref: https://argo-cd.readthedocs.io/en/stable/cli_installation/
"VERSION=$(curl -L -s https://raw.githubusercontent.com/argoproj/argo-cd/stable/VERSION)",
"curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/v$VERSION/argocd-linux-amd64",
"sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd",
"rm argocd-linux-amd64", 

# Install Java 17
# REF: https://www.rosehosting.com/blog/how-to-install-java-17-lts-on-ubuntu-20-04/
sudo apt update -y
sudo apt install openjdk-17-jdk openjdk-17-jre -y
java -version

# Install Jenkins
# REF: https://www.jenkins.io/doc/book/installing/linux/#debianubuntu
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update -y                                   # to update package
sudo apt install jenkins -y                          # to install jenkins
sudo systemctl start jenkins                         # to start jenkins service
# sudo systemctl status jenkins                        # to check the status if jenkins is running or not

# Get Jenkins_Public_IP
ip=$(curl ifconfig.me)
port1=8080
port2=9000

# Generate Jenkins initial login password
pass=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
echo "Access Jenkins Server here --> http://$ip:$port1"
echo "Jenkins Initial Password: $pass"
echo
echo "Access SonarQube Server here --> http://$ip:$port2"
echo "SonarQube Username & Password: admin"

# install git
sudo apt update -y
sudo apt install git -y

# install terraform
sudo apt-get update

# Install required packages
sudo apt-get install -y gnupg software-properties-common

# Add HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

# Verify the key's fingerprint
gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint

# Add the official HashiCorp repository to your system
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update package index again
sudo apt update

# Install Terraform
sudo apt-get install terraform

# install kubectl
sudo apt-get update

# Install required packages
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

# Download and add the Kubernetes signing key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add Kubernetes APT repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | \
sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update package index with new repository
sudo apt-get update

# Install kubectl
sudo apt-get install -y kubectl
sudo chmod +x ./kubectl
sudo mkdir -p $HOME/bin && sudo cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin 