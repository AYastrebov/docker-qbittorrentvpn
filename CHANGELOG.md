# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Multi-architecture support (AMD64 and ARM64)
- GitHub Actions CI/CD pipeline with security scanning
- Comprehensive production example configuration
- Enhanced documentation and setup guides
- Example configurations for different use cases
- Custom health check script example
- Security-focused Docker Compose configuration
- Container image labels for better metadata
- Trivy security scanning in CI/CD
- Monthly automated builds for security updates

### Changed
- Updated base image to Debian Trixie Slim
- Updated qBittorrent to v5.1.2
- Improved Docker Compose examples
- Enhanced README with better structure and navigation
- Fixed badge URLs for consistency
- Added comprehensive .dockerignore and .gitattributes

### Security
- Updated dependencies to latest versions
- Improved container security practices
- Added vulnerability scanning with Trivy
- Enhanced security options in example configurations

### Fixed
- Corrected qBittorrent version references in documentation
- Fixed case inconsistency in badge URLs
- Improved Docker image size badge accuracy

## [Previous Versions]

This project is a fork and continuation of DyonR/docker-qbittorrentvpn. 
For historical changes, see the original repository.

### Key Improvements Over Original
- **Modern CI/CD**: Automated builds via GitHub Actions
- **Multi-Architecture**: ARM64 and AMD64 support
- **Updated Base**: Latest Debian Trixie instead of older versions
- **Better Documentation**: Comprehensive guides and examples
- **Active Maintenance**: Regular updates and community support

---

## Version Schema

- **Major versions** (X.0.0): Breaking changes that require user action
- **Minor versions** (X.Y.0): New features and improvements, backward compatible  
- **Patch versions** (X.Y.Z): Bug fixes and minor improvements

## Notes

- All dates are in YYYY-MM-DD format
- This changelog started with the fork creation in 2024
- For issues and feature requests, see [GitHub Issues](https://github.com/AYastrebov/docker-qbittorrentvpn/issues)
