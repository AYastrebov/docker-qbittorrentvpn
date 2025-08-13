# [qBittorrent](https://github.com/qbittorrent/qBittorrent), WireGuard and OpenVPN

[![Docker Build](https://github.com/AYastrebov/docker-qbittorrentvpn/actions/workflows/docker-build.yml/badge.svg?event=push)](https://github.com/AYastrebov/docker-qbittorrentvpn/actions/workflows/docker-build.yml)
[![GitHub Container Registry](https://img.shields.io/badge/ghcr.io-docker--qbittorrentvpn-blue?logo=docker)](https://github.com/AYastrebov/docker-qbittorrentvpn/pkgs/container/docker-qbittorrentvpn)
[![GitHub Tag](https://img.shields.io/github/v/tag/AYastrebov/docker-qbittorrentvpn?sort=semver)](https://github.com/AYastrebov/docker-qbittorrentvpn/releases)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-yellow.svg)](https://opensource.org/licenses/GPL-3.0)

Docker container which runs the latest [qBittorrent](https://github.com/qbittorrent/qBittorrent)-nox client while connecting to WireGuard or OpenVPN with iptables killswitch to prevent IP leakage when the tunnel goes down.

**✨ Built and published automatically via GitHub Actions to GitHub Container Registry**

[preview]: https://raw.githubusercontent.com/DyonR/docker-templates/master/Screenshots/qbittorrentvpn/qbittorrentvpn-webui.png "qBittorrent WebUI"
![alt text][preview]

## Table of Contents
- [Docker Features](#docker-features)
- [Quick Start](#quick-start)
- [Production Example](#production-example)
- [Architecture & Build Information](#architecture--build-information)
- [Variables, Volumes, and Ports](#variables-volumes-and-ports)
- [Access the WebUI](#access-the-webui)
- [How to use WireGuard](#how-to-use-wireguard)
- [How to use OpenVPN](#how-to-use-openvpn)
- [Support & Issues](#support--issues)
- [Credits & Acknowledgments](#credits--acknowledgments)

# Docker Features
* **Base Image**: Debian Trixie Slim - latest stable Debian release
* **qBittorrent**: v5.1.2 compiled from source with latest dependencies
* **Multi-Architecture**: Supports both AMD64 and ARM64 platforms
* **Automated Builds**: Built and published via GitHub Actions to GitHub Container Registry
* **VPN Support**: Selectively enable WireGuard or OpenVPN with automatic configuration
* **Security**: IPtables killswitch prevents IP leaking when VPN connection fails
* **Flexibility**: Configurable UID/GID for file permissions and container management
* **Monitoring**: Built-in health checks and connection monitoring
* **Optimized**: Multi-stage build for minimal image size
* **Port Configuration**: BitTorrent port 8999 exposed by default
* **Unraid Ready**: Created with [Unraid](https://unraid.net/) in mind

## Quick Start

### Using Docker Run
The container is available from GitHub Container Registry and supports both AMD64 and ARM64 architectures.

```bash
docker run -d \
  --name qbittorrentvpn \
  -v /your/config/path/:/config \
  -v /your/downloads/path/:/downloads \
  -e "VPN_ENABLED=yes" \
  -e "VPN_TYPE=wireguard" \
  -e "LAN_NETWORK=192.168.0.0/24" \
  -p 8080:8080 \
  --cap-add NET_ADMIN \
  --sysctl "net.ipv4.conf.all.src_valid_mark=1" \
  --restart unless-stopped \
  ghcr.io/ayastrebov/docker-qbittorrentvpn:latest
```

### Using Docker Compose (Recommended)
Create a `docker-compose.yml` file:

```yaml
services:
  qbittorrentvpn:
    image: ghcr.io/ayastrebov/docker-qbittorrentvpn:latest
    container_name: qbittorrentvpn
    hostname: qbittorrentvpn
    environment:
      - TZ=Europe/Berlin                    # Set your timezone
      - VPN_ENABLED=yes
      - VPN_TYPE=wireguard                  # or 'openvpn'
      - RESTART_CONTAINER=yes
      - LAN_NETWORK=192.168.1.0/24          # Adjust to your local network
      - PUID=1000                           # Your user ID
      - PGID=1000                           # Your group ID
    volumes:
      - ./config:/config                    # qBittorrent and VPN configs
      - ./downloads:/downloads              # Download directory
    ports:
      - 8080:8080/tcp                       # qBittorrent WebUI
    cap_add:
      - NET_ADMIN                           # Required for VPN
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1  # Required for VPN
      - net.ipv6.conf.all.disable_ipv6=0    # Enable if using IPv6
    restart: unless-stopped
```

**Setup Steps:**
1. Create the directory structure:
   ```bash
   mkdir -p qbittorrent/{config,downloads}
   cd qbittorrent
   ```

2. Save the above content as `docker-compose.yml`

3. **For WireGuard**: Place your `wg0.conf` file in `./config/wireguard/`
   **For OpenVPN**: Place your `.ovpn` file in `./config/openvpn/`

4. Adjust the environment variables:
   - `TZ`: Your timezone (find yours [here](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones))
   - `LAN_NETWORK`: Your local network CIDR (check with `ip route | grep 192.168`)
   - `PUID`/`PGID`: Your user/group IDs (get with `id` command)

5. Start the container: `docker-compose up -d`

**💡 Pro Tip**: Check out the complete [`docker-compose.example.yml`](docker-compose.example.yml) file in this repository for a production-ready configuration with detailed comments and troubleshooting tips!

# Production Example

For a complete, production-ready setup, use the [`docker-compose.example.yml`](docker-compose.example.yml) file included in this repository. This example is based on a real working configuration and includes:

- **Comprehensive comments** explaining each setting
- **Timezone configuration** (TZ environment variable)
- **Proper file permissions** (PUID/PGID setup)
- **Network configuration** guidance
- **Complete setup instructions**
- **Troubleshooting tips**

**Quick setup using the example:**
```bash
# Clone or download the repository
wget https://raw.githubusercontent.com/AYastrebov/docker-qbittorrentvpn/master/docker-compose.example.yml

# Copy and customize
cp docker-compose.example.yml docker-compose.yml
nano docker-compose.yml  # Edit the configuration

# Create directories
mkdir -p config downloads

# Add your VPN config (WireGuard example)
mkdir -p config/wireguard
# Copy your wg0.conf file to config/wireguard/

# Start the container
docker-compose up -d
```

# Variables, Volumes, and Ports
## Environment Variables
| Variable | Required | Function | Example | Default |
|----------|----------|----------|----------|----------|
|`VPN_ENABLED`| Yes | Enable VPN (yes/no)?|`VPN_ENABLED=yes`|`yes`|
|`VPN_TYPE`| Yes | WireGuard or OpenVPN (wireguard/openvpn)?|`VPN_TYPE=wireguard`|`openvpn`|
|`VPN_USERNAME`| No | If username and password provided, configures ovpn file automatically |`VPN_USERNAME=ad8f64c02a2de`||
|`VPN_PASSWORD`| No | If username and password provided, configures ovpn file automatically |`VPN_PASSWORD=ac98df79ed7fb`||
|`LAN_NETWORK`| Yes (atleast one) | Comma delimited local Network's with CIDR notation |`LAN_NETWORK=192.168.0.0/24,10.10.0.0/24`||
|`LEGACY_IPTABLES`| No | Use `iptables (legacy)` instead of `iptables (nf_tables)` |`LEGACY_IPTABLES=yes`||
|`ENABLE_SSL`| No | Let the container handle SSL (yes/no)? |`ENABLE_SSL=yes`|`yes`|
|`NAME_SERVERS`| No | Comma delimited name servers |`NAME_SERVERS=1.1.1.1,1.0.0.1`|`1.1.1.1,1.0.0.1`|
|`PUID`| No | UID applied to /config files and /downloads |`PUID=99`|`99`|
|`PGID`| No | GID applied to /config files and /downloads  |`PGID=100`|`100`|
|`UMASK`| No | |`UMASK=002`|`002`|
|`HEALTH_CHECK_HOST`| No |This is the host or IP that the healthcheck script will use to check an active connection|`HEALTH_CHECK_HOST=one.one.one.one`|`one.one.one.one`|
|`HEALTH_CHECK_INTERVAL`| No |This is the time in seconds that the container waits to see if the internet connection still works (check if VPN died)|`HEALTH_CHECK_INTERVAL=300`|`300`|
|`HEALTH_CHECK_SILENT`| No |Set to `1` to supress the 'Network is up' message. Defaults to `1` if unset.|`HEALTH_CHECK_SILENT=1`|`1`|
|`HEALTH_CHECK_AMOUNT`| No |The amount of pings that get send when checking for connection.|`HEALTH_CHECK_AMOUNT=10`|`1`|
|`RESTART_CONTAINER`| No |Set to `no` to **disable** the automatic restart when the network is possibly down.|`RESTART_CONTAINER=yes`|`yes`|
|`INSTALL_PYTHON3`| No |Set this to `yes` to let the container install Python3.|`INSTALL_PYTHON3=yes`|`no`|
|`ADDITIONAL_PORTS`| No |Adding a comma delimited list of ports will allow these ports via the iptables script.|`ADDITIONAL_PORTS=1234,8112`||

## Volumes
| Volume | Required | Function | Example |
|----------|----------|----------|----------|
| `config` | Yes | qBittorrent, WireGuard and OpenVPN config files | `/your/config/path/:/config`|
| `downloads` | No | Default downloads path for saving downloads | `/your/downloads/path/:/downloads`|

## Ports
| Port | Proto | Required | Function | Example |
|----------|----------|----------|----------|----------|
| `8080` | TCP | Yes | qBittorrent WebUI | `8080:8080`|
| `8999` | TCP | Yes | qBittorrent TCP Listening Port | `8999:8999`|
| `8999` | UDP | Yes | qBittorrent UDP Listening Port | `8999:8999/udp`|

# Access the WebUI
Access https://IPADDRESS:PORT from a browser on the same network.  
**Example**: https://192.168.0.90:8080

## Default Credentials

| Credential | Default Value |
|----------|----------|
|`username`| `admin` |
|`password`| `adminadmin` |

⚠️ **Security Note**: Change the default password immediately after first login!

# Architecture & Build Information

## Supported Architectures
This image supports multiple architectures:
- `linux/amd64` - Intel/AMD 64-bit
- `linux/arm64` - ARM 64-bit (Apple Silicon, ARM servers)

## Automated Builds
- **CI/CD**: Automated builds via GitHub Actions
- **Registry**: Published to GitHub Container Registry (`ghcr.io`)
- **Triggers**: Builds automatically on version tags (`v*`)
- **Multi-platform**: Built for both AMD64 and ARM64 simultaneously

## Version Information
- **qBittorrent**: v5.1.2 (compiled from source)
- **Base OS**: Debian Trixie Slim
- **Build Tools**: CMake, Ninja, Qt6
- **VPN Support**: OpenVPN, WireGuard

You can find all available versions on the [releases page](https://github.com/AYastrebov/docker-qbittorrentvpn/releases).

## Container Registry Information
- **Registry**: `ghcr.io/ayastrebov/docker-qbittorrentvpn`
- **Tags Available**:
  - `latest` - Latest stable release
  - `vX.Y.Z` - Specific version tags
- **Packages**: View all versions on [GitHub Packages](https://github.com/AYastrebov/docker-qbittorrentvpn/pkgs/container/docker-qbittorrentvpn)

## Update Strategy
To update to the latest version:
```bash
docker pull ghcr.io/ayastrebov/docker-qbittorrentvpn:latest
docker-compose down && docker-compose up -d
```

# How to use WireGuard 
The container will fail to boot if `VPN_ENABLED` is set and there is no valid .conf file present in the /config/wireguard directory. Drop a .conf file from your VPN provider into /config/wireguard and start the container again. The file must have the name `wg0.conf`, or it will fail to start.

## WireGuard IPv6 issues
If you use WireGuard and also have IPv6 enabled, it is necessary to add the IPv6 range to the `LAN_NETWORK` environment variable.  
Additionally the parameter `--sysctl net.ipv6.conf.all.disable_ipv6=0` also must be added to the `docker run` command, or to the "Extra Parameters" in Unraid.  
The full Unraid `Extra Parameters` would be: `--restart unless-stopped --sysctl net.ipv6.conf.all.disable_ipv6=0"`  
If you do not do this, the container will keep on stopping with the error `RTNETLINK answers permission denied`.
Since I do not have IPv6, I am did not test.
Thanks to [mchangrh](https://github.com/mchangrh) / [Issue #49](https://github.com/DyonR/docker-qbittorrentvpn/issues/49)  

# How to use OpenVPN
The container will fail to boot if `VPN_ENABLED` is set and there is no valid .ovpn file present in the /config/openvpn directory. Drop a .ovpn file from your VPN provider into /config/openvpn (if necessary with additional files like certificates) and start the container again. You may need to edit the ovpn configuration file to load your VPN credentials from a file by setting `auth-user-pass`.

**Note:** The script will use the first ovpn file it finds in the /config/openvpn directory. Adding multiple ovpn files will not start multiple VPN connections.

## Example auth-user-pass option for .ovpn files
`auth-user-pass credentials.conf`

## Example credentials.conf
```
username
password
```

## PUID/PGID
User ID (PUID) and Group ID (PGID) can be found by issuing the following command for the user you want to run the container as:

```
id <username>
```

# Support & Issues

## Getting Help
If you are having issues with this container:

1. **Check the [Wiki](https://github.com/AYastrebov/docker-qbittorrentvpn/wiki)** (if available)
2. **Search [existing issues](https://github.com/AYastrebov/docker-qbittorrentvpn/issues)** to see if your problem has been reported
3. **Create a [new issue](https://github.com/AYastrebov/docker-qbittorrentvpn/issues/new)** with detailed information

## When Creating an Issue
Please provide:
- **Docker version**: `docker --version`
- **Container logs**: `docker logs qbittorrentvpn`
- **Your configuration**: docker-compose.yml or docker run command (remove sensitive data)
- **Host OS and kernel version**
- **Expected vs actual behavior**
- **Steps to reproduce the issue**

## Best Practices
- Always use the most up-to-date version of Docker and this container
- Keep your host OS and kernel updated
- Support is provided on a best-effort basis

## Contributing
Contributions are welcome! Please read the contribution guidelines and submit pull requests for any improvements.

## Project Status
This project is actively maintained and regularly updated with:
- Latest qBittorrent releases
- Security patches
- Community feature requests
- Bug fixes and improvements

## Credits & Acknowledgments

This project builds upon the excellent work of:
- **[DyonR/docker-qbittorrentvpn](https://github.com/DyonR/docker-qbittorrentvpn)** - Primary inspiration and base
- **[MarkusMcNugen/docker-qBittorrentvpn](https://github.com/MarkusMcNugen/docker-qBittorrentvpn)** - Original implementation
- **[DyonR/jackettvpn](https://github.com/DyonR/jackettvpn)** - VPN configuration patterns

### Why This Fork?
This project was created as an independent fork because DyonR/docker-qbittorrentvpn had already been forked from DyonR/jackettvpn, making a direct GitHub fork impossible. This version includes:
- **Modern CI/CD**: GitHub Actions automation
- **Multi-architecture**: ARM64 and AMD64 support
- **Updated base**: Latest Debian Trixie
- **Enhanced security**: Improved build process
- **Better documentation**: Comprehensive README

---

**⭐ If you find this project useful, please consider starring it on [GitHub](https://github.com/AYastrebov/docker-qbittorrentvpn)!**
