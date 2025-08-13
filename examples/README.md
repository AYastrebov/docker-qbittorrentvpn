# Example Configurations

This directory contains example configurations for different use cases:

## Files

- `docker-compose.wireguard.yml` - WireGuard VPN configuration
- `docker-compose.openvpn.yml` - OpenVPN configuration  
- `docker-compose.traefik.yml` - Setup with Traefik reverse proxy
- `docker-compose.unraid.yml` - Unraid-specific configuration
- `healthcheck.sh` - Custom healthcheck script example
- `vpn-configs/` - Example VPN configuration files

## Usage

1. Copy the relevant example file to your working directory
2. Rename it to `docker-compose.yml`
3. Adjust the configuration to match your environment
4. Add your VPN configuration files
5. Run with `docker-compose up -d`

## Notes

- Always review and customize the configurations before use
- Ensure proper file permissions on VPN configuration files
- Test in a development environment first
