# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.2.x   | :white_check_mark: |
| < 0.2   | :x:                |

## Reporting a Vulnerability

We take the security of Kodra seriously. If you discover a security vulnerability, please report it responsibly.

### How to Report

1. **Do NOT open a public GitHub issue** for security vulnerabilities
2. Email security concerns to: **security@codetocloud.io**
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect

- **Acknowledgment**: Within 48 hours of your report
- **Assessment**: We'll evaluate the severity within 7 days
- **Resolution**: Critical issues patched within 14 days
- **Disclosure**: Coordinated disclosure after fix is released

### Scope

Security issues in scope:

- Installation scripts that could execute malicious code
- Credential exposure in configs or logs
- Privilege escalation vulnerabilities
- Insecure default configurations
- Dependencies with known CVEs

### Out of Scope

- Issues in third-party tools (report to upstream maintainers)
- Social engineering attacks
- Physical attacks
- Issues requiring physical access to the device

## Security Best Practices

When using Kodra:

1. **Review before running**: Always review scripts before piping to bash
   ```bash
   # Download first, review, then run
   wget https://kodra.codetocloud.io/boot.sh
   less boot.sh
   bash boot.sh
   ```

2. **Use official sources only**: Only download from `kodra.codetocloud.io` or the official GitHub repository

3. **Keep updated**: Run `kodra update` regularly to get security patches

4. **Check signatures**: GPG signatures are verified for all package repositories

## Security Practices

Kodra follows these security practices:

### All Downloads Use HTTPS

Every download URL in the codebase uses HTTPS. No insecure HTTP connections are made.

### GPG Signature Verification

All apt repositories are configured with GPG key verification:
- Microsoft packages (Azure CLI, PowerShell)
- Docker official packages
- Kubernetes packages
- HashiCorp packages (Terraform)
- GitHub CLI packages
- Charm packages (gum)

### No Unsafe `eval` with User Input

`eval` is only used with trusted output from known commands:
- Shell initialization (brew shellenv, starship init, zoxide init, mise activate)
- Never with raw user input

### Input Validation

User inputs are validated before use:
- Theme names are checked against existing theme directories
- Font names are verified with fc-list
- File paths are validated and sanitized

### No Credential Storage

Kodra never stores credentials in config files:
- Azure CLI handles its own auth (~/.azure)
- GitHub CLI handles its own auth (~/.config/gh)
- Kubernetes uses standard kubeconfig

### Automated Dependency Updates

Dependabot is configured to keep GitHub Actions up to date automatically.

## Acknowledgments

We appreciate security researchers who help keep Kodra safe. Responsible disclosures will be acknowledged in release notes (with permission).

---

*This policy is based on industry best practices and may be updated periodically.*
