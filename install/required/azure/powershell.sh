#!/usr/bin/env bash
#
# PowerShell 7 Installer
# https://docs.microsoft.com/en-us/powershell/scripting/install/install-ubuntu
#

set -e

if command -v pwsh &> /dev/null; then
    echo "PowerShell already installed: $(pwsh --version)"
    exit 0
fi

echo "Installing PowerShell 7..."

# Get Ubuntu version
source /etc/os-release
UBUNTU_VERSION="$VERSION_ID"

# Download Microsoft GPG key
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | \
    sudo gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg

# Add Microsoft package repository
echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/ubuntu/${UBUNTU_VERSION}/prod ${UBUNTU_CODENAME} main" | \
    sudo tee /etc/apt/sources.list.d/microsoft-prod.list

# Update and install
sudo apt-get update
sudo apt-get install -y powershell

# Setup completions
mkdir -p ~/.local/share/bash-completion/completions
mkdir -p ~/.config/zsh/completions
mkdir -p ~/.config/powershell

# Create PowerShell profile with useful defaults
cat > ~/.config/powershell/Microsoft.PowerShell_profile.ps1 << 'EOF'
# Kodra PowerShell Profile
# Beautiful prompt and useful defaults

# Oh My Posh prompt (if installed)
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh | Invoke-Expression
}

# Aliases matching bash/zsh
Set-Alias -Name k -Value kubectl
Set-Alias -Name h -Value helm
Set-Alias -Name g -Value git
Set-Alias -Name tf -Value terraform
Set-Alias -Name lg -Value lazygit
Set-Alias -Name ld -Value lazydocker

# PSReadLine configuration
if (Get-Module -ListAvailable -Name PSReadLine) {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
}

# kubectl completions
if (Get-Command kubectl -ErrorAction SilentlyContinue) {
    kubectl completion powershell | Out-String | Invoke-Expression
}

# helm completions
if (Get-Command helm -ErrorAction SilentlyContinue) {
    helm completion powershell | Out-String | Invoke-Expression
}

# Azure CLI completions
if (Get-Command az -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -Native -CommandName az -ScriptBlock {
        param($commandName, $wordToComplete, $cursorPosition)
        $completion_file = New-TemporaryFile
        $env:ARGCOMPLETE_USE_TEMPFILES = 1
        $env:_ARGCOMPLETE_STDOUT_FILENAME = $completion_file
        $env:COMP_LINE = $wordToComplete
        $env:COMP_POINT = $cursorPosition
        $env:_ARGCOMPLETE = 1
        $env:_ARGCOMPLETE_SUPPRESS_SPACE = 0
        $env:_ARGCOMPLETE_IFS = "`n"
        az 2>&1 | Out-Null
        Get-Content $completion_file | Where-Object { $_ -ne '' }
        Remove-Item $completion_file, Env:\_ARGCOMPLETE_STDOUT_FILENAME, Env:\ARGCOMPLETE_USE_TEMPFILES, Env:\COMP_LINE, Env:\COMP_POINT, Env:\_ARGCOMPLETE, Env:\_ARGCOMPLETE_SUPPRESS_SPACE, Env:\_ARGCOMPLETE_IFS -ErrorAction SilentlyContinue
    }
}

Write-Host "☁️  Kodra PowerShell | Type 'Get-Alias' for shortcuts" -ForegroundColor Cyan
EOF

# Verify installation
pwsh --version

echo "PowerShell 7 installed successfully!"
echo "  Run 'pwsh' to start PowerShell"
echo "  Profile configured at ~/.config/powershell/Microsoft.PowerShell_profile.ps1"
echo "  Includes: kubectl, helm, az completions + aliases"
