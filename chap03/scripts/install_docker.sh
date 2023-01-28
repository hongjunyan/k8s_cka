# Set up the repository

sudo apt-get remove docker docker-engine docker.io containerd runc

## 1. Update the apt package index and install packages to allow apt to use a repository over HTTPS:
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

## 2. Use the following command to set up the repository:
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 3. Install Docker Engine
sudo apt-get update
# sudo apt-get install -y docker-ce=5:19.03.10~3-0~ubuntu-focal docker-ce-cli=5:19.03.10~3-0~ubuntu-focal containerd.io docker-compose-plugin
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 4. Restart docker
sudo service docker stop && sudo service docker start

# 5. Add your account to docker group
sudo usermod -aG docker $USER

# if run k8s >=1.25, please install cri-docker first
wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.0/cri-dockerd_0.3.0.3-0.ubuntu-focal_amd64.deb
sudo dpkg -i cri-dockerd_0.3.0.3-0.ubuntu-focal_amd64.deb
# In slave join token, must add --cri-socket=/run/cri-dockerd.sock