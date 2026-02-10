#!/usr/bin/env bash
#
# Kodra Docker Test Script
# Runs full installation test in Ubuntu 24.04 container
#
# Usage: ./tests/docker-test.sh [--interactive]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KODRA_DIR="$(dirname "$SCRIPT_DIR")"
INTERACTIVE=false

for arg in "$@"; do
    case $arg in
        -i|--interactive)
            INTERACTIVE=true
            shift
            ;;
    esac
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Kodra Docker Test Suite"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Building Ubuntu 24.04 test container..."
echo ""

# Create Dockerfile
cat > /tmp/kodra-test.dockerfile << 'EOF'
FROM ubuntu:24.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install minimal dependencies
RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    wget \
    git \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Create test user with sudo access
RUN useradd -m -s /bin/bash kodra && \
    echo "kodra ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER kodra
WORKDIR /home/kodra

# Copy local kodra repo for testing (optional)
# COPY --chown=kodra:kodra . /home/kodra/.kodra-local

CMD ["/bin/bash"]
EOF

# Build the image
docker build -t kodra-test -f /tmp/kodra-test.dockerfile . 2>&1 | while read line; do
    echo "  $line"
done

echo ""
echo "Container built successfully!"
echo ""

if [ "$INTERACTIVE" = true ]; then
    echo "Starting interactive container..."
    echo "Run: curl -fsSL https://kodra.codetocloud.io/boot.sh | bash"
    echo ""
    docker run -it --rm \
        -v "$KODRA_DIR:/home/kodra/.kodra-local:ro" \
        kodra-test /bin/bash
else
    echo "Running automated boot.sh test..."
    echo ""
    
    # Create test script to run inside container
    cat > /tmp/kodra-container-test.sh << 'TESTEOF'
#!/bin/bash
set -x  # Show all commands

echo "=============================================="
echo "STEP 1: Testing boot.sh download"
echo "=============================================="
START=$(date +%s)
curl -fsSL https://kodra.codetocloud.io/boot.sh -o /tmp/boot.sh
END=$(date +%s)
echo "Download time: $((END - START)) seconds"
echo ""

echo "=============================================="
echo "STEP 2: Checking boot.sh syntax"
echo "=============================================="
bash -n /tmp/boot.sh && echo "Syntax OK" || echo "SYNTAX ERROR"
echo ""

echo "=============================================="
echo "STEP 3: Running boot.sh with --install flag"
echo "=============================================="
# Use timeout to catch hangs (10 minutes max for full install)
timeout 600 bash /tmp/boot.sh --install --debug 2>&1 || {
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 124 ]; then
        echo ""
        echo "!!! TIMEOUT - Script hung after 10 minutes !!!"
    else
        echo ""
        echo "Exit code: $EXIT_CODE"
    fi
}

echo ""
echo "=============================================="
echo "TEST COMPLETE"
echo "=============================================="
TESTEOF

    chmod +x /tmp/kodra-container-test.sh
    
    # Run the test with timeout tracking
    docker run --rm \
        -v /tmp/kodra-container-test.sh:/home/kodra/test.sh:ro \
        kodra-test bash /home/kodra/test.sh
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Test Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
