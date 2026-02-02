# Base image with essential build dependencies
ARG DEBIAN_VERSION=trixie-slim
FROM debian:${DEBIAN_VERSION} AS builder
WORKDIR /opt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies from official repositories
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
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
    zlib1g-dev

# Fetch and compile qBittorrent
ARG QBITTORRENT_VERSION=5.1.2
RUN curl -L -o qbittorrent.tar.gz "https://sourceforge.net/projects/qbittorrent/files/qbittorrent/qbittorrent-${QBITTORRENT_VERSION}/qbittorrent-${QBITTORRENT_VERSION}.tar.gz/download" && \
    tar -xzf qbittorrent.tar.gz --strip-components=1 && rm qbittorrent.tar.gz && \
    cmake -G Ninja -B build -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr/local -DGUI=OFF && \
    cmake --build build --parallel $(nproc) && \
    cmake --install build

# Final minimal runtime image
ARG DEBIAN_VERSION
FROM debian:${DEBIAN_VERSION}
WORKDIR /opt
ENV DEBIAN_FRONTEND=noninteractive

# Install only required runtime dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    dos2unix \
    iproute2 \
    inetutils-ping \
    ipcalc \
    iptables \
    moreutils \
    openresolv \
    openvpn \
    wireguard-tools \
    libtorrent-rasterbar2.0 \
    libqt6core6 \
    libqt6network6 \
    libqt6sql6 \
    libqt6xml6 \
    kmod \
    procps

# Copy compiled qBittorrent binary (changes rarely)
COPY --from=builder /usr/local /usr/local

# Static system modifications
RUN sed -i /net\.ipv4\.conf\.all\.src_valid_mark/d $(which wg-quick)

# Copy scripts and configurations (may change more often)
COPY openvpn/ /etc/openvpn/
COPY qbittorrent/ /etc/qbittorrent/

# Set executable permissions
RUN chmod 755 /etc/qbittorrent/*.sh /etc/qbittorrent/*.init /etc/openvpn/*.sh

# Persist config and downloads
VOLUME /config /downloads

# Expose ports
EXPOSE 8080 8999 8999/udp

# Health check for container orchestration
HEALTHCHECK --interval=60s --timeout=15s --start-period=120s --retries=3 \
    CMD curl -sf http://localhost:8080 > /dev/null && ping -c 1 -W 5 one.one.one.one > /dev/null || exit 1

# Add build metadata
ARG QBITTORRENT_VERSION
LABEL org.opencontainers.image.version="${QBITTORRENT_VERSION}" \
      org.opencontainers.image.title="qBittorrent VPN Docker" \
      org.opencontainers.image.description="qBittorrent with WireGuard/OpenVPN and iptables killswitch" \
      org.opencontainers.image.url="https://github.com/AYastrebov/docker-qbittorrentvpn" \
      org.opencontainers.image.source="https://github.com/AYastrebov/docker-qbittorrentvpn" \
      org.opencontainers.image.vendor="AYastrebov" \
      org.opencontainers.image.licenses="GPL-3.0"

# Set default startup command
CMD ["/bin/bash", "/etc/openvpn/start.sh"]
