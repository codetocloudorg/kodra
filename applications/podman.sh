#!/usr/bin/env bash
#
# Podman Installer
# Daemonless container engine - alternative to Docker
# https://podman.io/docs/installation
#

set -e

if command -v podman &> /dev/null; then
    echo "Podman already installed: $(podman --version)"
    exit 0
fi

# Install Podman from Ubuntu repos (24.04 has recent version)
sudo apt-get update
sudo apt-get install -y podman podman-compose

# Create docker alias for compatibility
if [ ! -f /usr/local/bin/docker ]; then
    sudo bash -c 'cat > /usr/local/bin/docker << "EOF"
#!/bin/bash
# Docker compatibility wrapper for Podman
podman "$@"
EOF'
    sudo chmod +x /usr/local/bin/docker
fi

# Verify installation
podman --version

echo ""
echo "Podman installed successfully!"
echo ""
echo "Podman is a drop-in replacement for Docker."
echo "Commands: podman run, podman build, podman-compose"
echo ""
echo "Note: For VS Code Dev Containers, add to settings.json:"
echo '  "dev.containers.dockerPath": "podman"'
