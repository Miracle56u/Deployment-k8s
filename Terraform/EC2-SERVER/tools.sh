
#!/bin/bash

# Update system first
echo "Updating system..."
sudo yum update -y
check_status "System update"

# Install essential tools first
echo "Installing essential tools..."
sudo yum install -y unzip wget curl git yum-utils
check_status "Essential tools installation"

# Install AWS CLI
echo "Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws/
check_status "AWS CLI installation"

# Install Java (required for Jenkins and SonarQube)
echo "Installing Java 17..."
sudo yum install -y java-17-amazon-corretto-devel
check_status "Java installation"

# Install Docker
echo "Installing Docker..."
sudo yum install -y docker
sudo usermod -aG docker ec2-user
sudo systemctl start docker
sudo systemctl enable docker
sudo chmod 666 /var/run/docker.sock
check_status "Docker installation"

# Install Jenkins
echo "Installing Jenkins..."
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
# Wait for Jenkins to start
sleep 30
check_status "Jenkins installation"

# Install SonarQube
echo "Installing SonarQube..."
sudo useradd sonar || true  # Don't fail if user exists
cd /opt
sudo wget -q https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.0.65466.zip
sudo unzip -q sonarqube-9.9.0.65466.zip
sudo mv sonarqube-9.9.0.65466 sonarqube
sudo chown -R sonar:sonar /opt/sonarqube

# Create SonarQube service
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

sudo systemctl daemon-reload
sudo systemctl start sonarqube
sudo systemctl enable sonarqube
sudo rm -f /opt/sonarqube-9.9.0.65466.zip
check_status "SonarQube installation"

# Install Trivy
echo "Installing Trivy..."
sudo rpm --import https://aquasecurity.github.io/trivy-repo/rpm/public.key
echo -e '[trivy]\nname=Trivy repository\nbaseurl=https://aquasecurity.github.io/trivy-repo/rpm/releases/$basearch/\ngpgcheck=1\nenabled=1' | sudo tee /etc/yum.repos.d/trivy.repo
sudo yum install -y trivy
check_status "Trivy installation"

# Install Helm
echo "Installing Helm..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm get_helm.sh
check_status "Helm installation"

# Install kubectl
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
check_status "kubectl installation"

# Install ArgoCD CLI only (not the server - that needs a K8s cluster)
echo "Installing ArgoCD CLI..."
VERSION=$(curl -L -s https://raw.githubusercontent.com/argoproj/argo-cd/stable/VERSION)
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/v$VERSION/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
check_status "ArgoCD CLI installation"

# Install Terraform
echo "Installing Terraform..."
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install -y terraform
check_status "Terraform installation"

# Set proper permissions for ec2-user
echo "Setting up user permissions..."
sudo usermod -aG docker ec2-user

# Final status check
echo "Checking service status..."
sudo systemctl status jenkins --no-pager
sudo systemctl status docker --no-pager
sudo systemctl status sonarqube --no-pager

echo "User data script completed at $(date)"
echo "=== Installation Summary ==="
echo "Jenkins: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo "SonarQube: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9000"
echo "=== End Summary ==="