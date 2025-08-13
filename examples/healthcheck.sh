#!/bin/bash
# Custom health check script for qBittorrent VPN Docker container
# Place this in your config directory and mount it to the container

set -e

# Configuration
QBITTORRENT_URL="http://localhost:8080"
VPN_CHECK_HOST="${HEALTH_CHECK_HOST:-one.one.one.one}"
TIMEOUT=10

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

# Check if qBittorrent WebUI is responding
check_qbittorrent() {
    log "Checking qBittorrent WebUI..."
    if curl -f -s --max-time $TIMEOUT "$QBITTORRENT_URL/api/v2/app/version" > /dev/null; then
        log "✓ qBittorrent WebUI is responding"
        return 0
    else
        error "✗ qBittorrent WebUI is not responding"
        return 1
    fi
}

# Check VPN connectivity
check_vpn() {
    log "Checking VPN connectivity to $VPN_CHECK_HOST..."
    if ping -c 1 -W $TIMEOUT "$VPN_CHECK_HOST" > /dev/null 2>&1; then
        log "✓ VPN connectivity is working"
        return 0
    else
        error "✗ VPN connectivity failed"
        return 1
    fi
}

# Check if VPN interface is up
check_vpn_interface() {
    log "Checking VPN interfaces..."
    if ip link show | grep -E "(wg0|tun0)" > /dev/null; then
        local interface=$(ip link show | grep -E "(wg0|tun0)" | cut -d: -f2 | tr -d ' ')
        log "✓ VPN interface $interface is up"
        return 0
    else
        warn "No VPN interface found (this might be normal if VPN_ENABLED=no)"
        return 0
    fi
}

# Main health check
main() {
    log "Starting health check..."
    
    local exit_code=0
    
    # Run checks
    check_qbittorrent || exit_code=1
    check_vpn_interface || exit_code=1
    
    # Only check VPN connectivity if VPN is enabled
    if [ "${VPN_ENABLED:-yes}" = "yes" ]; then
        check_vpn || exit_code=1
    fi
    
    if [ $exit_code -eq 0 ]; then
        log "✓ All health checks passed"
    else
        error "✗ Health check failed"
    fi
    
    exit $exit_code
}

# Run main function
main "$@"
