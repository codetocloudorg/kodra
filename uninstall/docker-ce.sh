#!/usr/bin/env bash
#
# Uninstall Docker CE
#

set -e

echo "Removing Docker CE..."

# Stop and remove all containers
if command -v docker &>/dev/null; then
    echo "Stopping all containers..."
    docker stop $(docker ps -aq) 2>/dev/null || true
    docker rm $(docker ps -aq) 2>/dev/null || true
    
    echo "Removing Docker data..."
    docker system prune -af --volumes 2>/dev/null || true
fi

# Remove packages
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null || true
sudo apt-get autoremove -y

# Remove Docker data directories
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd

# Remove Docker group (user will remain in group until logout)
sudo groupdel docker 2>/dev/null || true

# Remove repository
sudo rm -f /etc/apt/sources.list.d/docker.list
sudo rm -f /etc/apt/keyrings/docker.gpg

echo "Docker CE uninstalled."
echo "Note: You may need to log out and back in for group changes to take effect."
