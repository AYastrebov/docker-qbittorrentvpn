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
ARG QBITTORRENT_VERSION=5.0.4
RUN curl -L -o qbittorrent.tar.gz "https://sourceforge.net/projects/qbittorrent/files/qbittorrent/qbittorrent-${QBITTORRENT_VERSION}/qbittorrent-${QBITTORRENT_VERSION}.tar.gz/download" && \
    tar -xzf qbittorrent.tar.gz --strip-components=1 && rm qbittorrent.tar.gz && \
    cmake -G Ninja -B build -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr/local -DGUI=OFF && \
    cmake --build build --parallel $(nproc) && \
    cmake --install build

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
