# Contributing to docker-qbittorrentvpn

Thank you for your interest in contributing to this project! We welcome contributions from the community.

## Ways to Contribute

- 🐛 **Report bugs** - Help us identify and fix issues
- 💡 **Suggest features** - Propose new functionality or improvements
- 📝 **Improve documentation** - Help make our docs clearer
- 🔧 **Submit code changes** - Fix bugs or implement features
- 🧪 **Test new releases** - Help validate changes before release

## Getting Started

### Prerequisites
- Docker and Docker Compose
- Basic understanding of containerization
- Familiarity with VPN configurations (WireGuard/OpenVPN)

### Development Setup
1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/docker-qbittorrentvpn.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test thoroughly (see Testing section below)
6. Commit and push your changes
7. Create a Pull Request

## Testing Your Changes

### Local Testing
```bash
# Build the container locally
docker build -t qbittorrentvpn:test .

# Test with your docker-compose.yml
docker-compose -f docker-compose.example.yml up -d

# Check logs
docker-compose logs -f qbittorrentvpn

# Test functionality
# - Verify VPN connection
# - Test qBittorrent WebUI access
# - Validate download functionality
```

### Test Scenarios
Please test these scenarios when making changes:
- ✅ Container starts successfully
- ✅ VPN connection establishes
- ✅ qBittorrent WebUI is accessible
- ✅ Downloads work correctly
- ✅ VPN killswitch functions properly
- ✅ Container restarts gracefully

## Submitting Changes

### Pull Request Guidelines
1. **Clear title**: Describe what your PR does
2. **Detailed description**: Explain the why and how
3. **Link issues**: Reference any related issues
4. **Test results**: Include test outcomes
5. **Screenshots**: For UI changes, include before/after images

### Commit Message Format
Use clear, descriptive commit messages:
```
feat: add support for custom DNS servers
fix: resolve VPN connection timeout issue
docs: update installation instructions
```

### Code Style
- Follow existing code patterns
- Use clear variable names
- Comment complex logic
- Keep changes focused and atomic

## Reporting Issues

### Bug Reports
When reporting bugs, please include:
- **Environment details**: OS, Docker version, container version
- **Configuration**: Your docker-compose.yml (remove sensitive data)
- **Steps to reproduce**: Clear reproduction steps
- **Expected vs actual behavior**
- **Logs**: Relevant container logs
- **Screenshots**: If applicable

### Feature Requests
For new features, please provide:
- **Use case**: Why is this feature needed?
- **Proposed solution**: How should it work?
- **Alternatives considered**: Other approaches you've thought of
- **Additional context**: Any other relevant information

## Development Guidelines

### Docker Best Practices
- Keep images small and efficient
- Use multi-stage builds when appropriate
- Follow security best practices
- Minimize layers and optimize for caching

### Documentation
- Update README.md for user-facing changes
- Update CHANGELOG.md for version releases
- Add inline comments for complex code
- Include examples for new features

### Security Considerations
- Never commit sensitive data (passwords, keys, etc.)
- Review third-party dependencies for vulnerabilities
- Follow secure coding practices
- Test security-related changes thoroughly

## Community Guidelines

### Code of Conduct
- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Assume good intentions

### Communication
- Use GitHub Issues for bug reports and feature requests
- Use Pull Requests for code contributions
- Be patient - maintainers are volunteers
- Provide context and details in discussions

## Release Process

Releases follow semantic versioning (semver):
- **Major (X.0.0)**: Breaking changes
- **Minor (X.Y.0)**: New features, backward compatible
- **Patch (X.Y.Z)**: Bug fixes, backward compatible

## Getting Help

- 📖 Check the [README.md](README.md) first
- 🔍 Search existing [issues](https://github.com/AYastrebov/docker-qbittorrentvpn/issues)
- 💬 Create a new issue for questions or problems
- 📧 For sensitive security issues, contact maintainers directly

## Recognition

Contributors are recognized in:
- GitHub's contributor graph
- Release notes for significant contributions
- Special thanks in project documentation

Thank you for contributing to make this project better! 🚀
