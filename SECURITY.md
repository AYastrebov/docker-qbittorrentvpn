# Security Policy

## Supported Versions

We provide security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |
| v1.x.x  | :white_check_mark: |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security vulnerability in this project, please report it responsibly.

### For Security Issues:

**🚨 Please DO NOT open a public GitHub issue for security vulnerabilities.**

Instead, please:

1. **Email us directly** at: [security contact - add your email]
2. **Use GitHub's private vulnerability reporting** (if available)
3. **Contact via other secure channels** if needed

### What to Include:

When reporting a security vulnerability, please include:

- **Description**: Clear description of the vulnerability
- **Impact**: What could an attacker accomplish?
- **Reproduction**: Step-by-step instructions to reproduce
- **Environment**: Docker version, host OS, container configuration
- **Proposed fix**: If you have suggestions for fixing the issue

### Response Timeline:

- **Acknowledgment**: Within 2-3 business days
- **Initial assessment**: Within 1 week
- **Status updates**: Weekly until resolved
- **Fix release**: Depends on severity and complexity

### Security Best Practices

When using this container, please follow these security guidelines:

#### Container Security
- ✅ **Run as non-root**: Container runs as specified PUID/PGID
- ✅ **Use secrets management**: Don't put VPN credentials in environment variables
- ✅ **Keep updated**: Regularly update to latest container version
- ✅ **Monitor logs**: Watch for unusual activity in container logs

#### VPN Security
- ✅ **Use strong VPN providers**: Choose reputable VPN services
- ✅ **Rotate credentials**: Regularly update VPN passwords/certificates
- ✅ **Verify killswitch**: Test that traffic stops when VPN disconnects
- ✅ **Monitor connections**: Ensure VPN is actually connected

#### Network Security
- ✅ **Restrict access**: Limit WebUI access to trusted networks only
- ✅ **Use HTTPS**: Enable SSL/TLS for WebUI when possible
- ✅ **Firewall rules**: Implement proper firewall configurations
- ✅ **Monitor traffic**: Watch for unexpected network activity

#### File System Security
- ✅ **Secure volumes**: Protect config and download directories
- ✅ **File permissions**: Use appropriate PUID/PGID settings
- ✅ **Backup encryption**: Encrypt sensitive configuration backups
- ✅ **Regular cleanup**: Remove old/unnecessary files

### Common Security Considerations

#### VPN Configuration
- Ensure your VPN configuration files don't contain embedded credentials
- Use `auth-user-pass` with separate credentials file
- Regularly rotate VPN certificates and keys
- Verify VPN provider's security practices

#### Container Networking
- The container requires `NET_ADMIN` capability for VPN functionality
- This is necessary but should be understood as a security consideration
- Ensure your host system is properly secured
- Consider using dedicated VPN-only network namespaces

#### Data Protection
- Download directories may contain sensitive content
- Ensure proper file system permissions
- Consider encryption for downloaded content
- Implement backup strategies for configuration

### Known Security Features

#### Built-in Protections
- **VPN Killswitch**: Prevents traffic leakage when VPN disconnects
- **IPTables rules**: Blocks non-VPN traffic automatically  
- **Process isolation**: Container runs isolated from host system
- **Non-root execution**: Processes run as specified user/group

#### Monitoring Capabilities
- **Health checks**: Built-in connection monitoring
- **Logging**: Comprehensive logging of VPN and application status
- **Restart policies**: Automatic recovery from connection failures

### Disclosure Policy

We believe in coordinated disclosure:

1. **Private reporting**: Report security issues privately first
2. **Collaborative fixing**: Work together to develop and test fixes
3. **Coordinated release**: Announce fixes after they're available
4. **Public disclosure**: Full details shared after fixes are deployed

### Security Updates

Security updates are prioritized and released as soon as possible:

- **Critical**: Emergency patches within 24-48 hours
- **High**: Patches within 1 week
- **Medium**: Patches in next regular release
- **Low**: Patches in next major release

Security updates are tagged with `[SECURITY]` in release notes.

---

Thank you for helping keep this project secure! 🔒
