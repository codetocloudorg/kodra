#!/usr/bin/env bash
#
# Docker CE (Community Edition) Installer
# Recommended container runtime for cloud developers
# https://docs.docker.com/engine/install/ubuntu/
#

set -e

if command -v docker &> /dev/null; then
    echo "Docker already installed: $(docker --version)"
    exit 0
fi

# Remove any old versions
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    sudo apt-get remove -y $pkg 2>/dev/null || true
done

# Add Docker's official GPG key
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker CE
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to docker group (avoids needing sudo)
sudo usermod -aG docker $USER

# Enable and start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Verify installation
docker --version

echo ""
echo "Docker CE installed successfully!"
echo ""
echo "NOTE: Log out and back in for docker group membership to take effect."
echo "Or run: newgrp docker"
echo ""
echo "Get started:"
echo "  docker run hello-world      Test your installation"
echo "  docker compose up           Start services from docker-compose.yml"
