# Kodra Development & Testing Container
# Base image for CI testing and local development
#
# Usage:
#   docker build -t kodra:dev .
#   docker run -it kodra:dev bash
#   docker run -it kodra:dev kodra doctor
#

FROM ubuntu:24.04

LABEL org.opencontainers.image.title="Kodra"
LABEL org.opencontainers.image.description="Cloud-native developer environment for Ubuntu"
LABEL org.opencontainers.image.source="https://github.com/codetocloudorg/kodra"
LABEL org.opencontainers.image.version="0.5.0"

ENV DEBIAN_FRONTEND=noninteractive
ENV KODRA_DIR=/opt/kodra
ENV PATH="/usr/local/bin:/opt/kodra/bin:${PATH}"
ENV TERM=xterm-256color
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Core system packages (subset of kodra-base.packages suitable for containers)
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    wget \
    git \
    unzip \
    zip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    bash-completion \
    zsh \
    tmux \
    tree \
    jq \
    bat \
    fd-find \
    ripgrep \
    fzf \
    htop \
    openssh-client \
    fontconfig \
    python3 \
    python3-pip \
    python3-venv \
    sudo \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Generate locale
RUN locale-gen en_US.UTF-8 || true

# Install Starship prompt
RUN curl -fsSL https://starship.rs/install.sh -o /tmp/starship-install.sh \
    && chmod +x /tmp/starship-install.sh \
    && /tmp/starship-install.sh --yes \
    && rm /tmp/starship-install.sh

# Install eza (modern ls)
RUN mkdir -p /etc/apt/keyrings \
    && wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list \
    && apt-get update -qq && apt-get install -y eza \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list \
    && apt-get update -qq && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Install zoxide (installs to ~/.local/bin by default, move to /usr/local/bin)
RUN curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh -o /tmp/zoxide-install.sh \
    && chmod +x /tmp/zoxide-install.sh \
    && HOME=/tmp /tmp/zoxide-install.sh \
    && mv /tmp/.local/bin/zoxide /usr/local/bin/zoxide \
    && rm -rf /tmp/zoxide-install.sh /tmp/.local

# Copy Kodra into /opt/kodra (system-wide)
COPY . /opt/kodra/

# Set permissions
RUN chmod -R a+rX /opt/kodra \
    && chmod +x /opt/kodra/bin/kodra \
    && ln -sf /opt/kodra/bin/kodra /usr/local/bin/kodra

# Create default user
RUN useradd -m -s /bin/bash -G sudo kodra \
    && echo "kodra ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/kodra \
    && mkdir -p /home/kodra/.config/kodra \
    && chown -R kodra:kodra /home/kodra

# Setup shell integration for default user
RUN echo '# Kodra shell integration' >> /home/kodra/.bashrc \
    && echo 'export KODRA_DIR="/opt/kodra"' >> /home/kodra/.bashrc \
    && echo 'export PATH="/opt/kodra/bin:$PATH"' >> /home/kodra/.bashrc \
    && echo '[ -f "$KODRA_DIR/configs/shell/aliases.sh" ] && source "$KODRA_DIR/configs/shell/aliases.sh"' >> /home/kodra/.bashrc \
    && echo 'eval "$(starship init bash)"' >> /home/kodra/.bashrc \
    && echo 'eval "$(zoxide init bash)"' >> /home/kodra/.bashrc

# Copy starship config
RUN mkdir -p /home/kodra/.config \
    && cp -r /opt/kodra/defaults/starship /home/kodra/.config/starship 2>/dev/null || true \
    && chown -R kodra:kodra /home/kodra

USER kodra
WORKDIR /home/kodra

# Health check
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD kodra --version || exit 1

CMD ["/bin/bash"]
