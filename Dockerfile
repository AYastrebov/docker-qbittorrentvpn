# Base image with essential build dependencies
FROM debian:trixie-slim AS builder
WORKDIR /opt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies from official repositories
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    ninja-build \
    pkg-config \
    qt6-base-dev \
    qt6-tools-dev \
    qt6-base-private-dev \
    libboost-dev \
    libssl-dev \
    libtorrent-rasterbar-dev \
    zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

# Fetch and compile qBittorrent
ARG QBITTORRENT_VERSION=5.2.3
RUN curl -L -o qbittorrent.tar.gz "https://github.com/qbittorrent/qBittorrent/archive/refs/tags/release-${QBITTORRENT_VERSION}.tar.gz" && \
    tar -xzf qbittorrent.tar.gz --strip-components=1 && rm qbittorrent.tar.gz && \
    cmake -G Ninja -B build -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr/local -DGUI=OFF && \
    cmake --build build --parallel $(nproc) && \
    cmake --install build

# Add build metadata
LABEL org.opencontainers.image.version="${QBITTORRENT_VERSION}"
LABEL org.opencontainers.image.title="qBittorrent VPN Docker"
LABEL org.opencontainers.image.description="qBittorrent with WireGuard/OpenVPN and iptables killswitch"
LABEL org.opencontainers.image.url="https://github.com/AYastrebov/docker-qbittorrentvpn"
LABEL org.opencontainers.image.source="https://github.com/AYastrebov/docker-qbittorrentvpn"
LABEL org.opencontainers.image.vendor="AYastrebov"
LABEL org.opencontainers.image.licenses="GPL-3.0"

# Final minimal runtime image
FROM debian:trixie-slim
WORKDIR /opt
ENV DEBIAN_FRONTEND=noninteractive

# Install only required runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    dos2unix \
    iproute2 \
    inetutils-ping \
    ipcalc \
    iptables \
    moreutils \
    net-tools \
    openresolv \
    openvpn \
    wireguard-tools \
    libtorrent-rasterbar2.0 \
    libqt6core6 \
    libqt6network6 \
    libqt6sql6 \
    libqt6xml6 \
    kmod \
    procps && \
    rm -rf /var/lib/apt/lists/*

# Copy compiled qBittorrent binary
COPY --from=builder /usr/local /usr/local

# Remove src_valid_mark from wg-quick
RUN sed -i /net\.ipv4\.conf\.all\.src_valid_mark/d $(which wg-quick)

# Persist config and downloads
VOLUME /config /downloads

# Copy scripts and configurations
COPY openvpn/ /etc/openvpn/
COPY qbittorrent/ /etc/qbittorrent/

# Set executable permissions
RUN chmod 755 /etc/qbittorrent/*.sh /etc/qbittorrent/*.init /etc/openvpn/*.sh

# Expose ports
EXPOSE 8080 8999 8999/udp

# Set default startup command
CMD ["/bin/bash", "/etc/openvpn/start.sh"]
