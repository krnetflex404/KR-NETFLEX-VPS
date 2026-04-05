FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install packages
RUN apt update && apt install -y \
    curl \
    wget \
    socat \
    openssl \
    ca-certificates \
    iproute2 \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# Install Xray
RUN bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# Install 3x-ui
RUN bash -c "$(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)"

# Create required dirs
RUN mkdir -p /usr/local/x-ui/bin && touch /usr/local/x-ui/bin/config.json

# Default PORT for Railway
ENV PORT=8080

# Start script
CMD bash -c '\
/usr/local/x-ui/x-ui & \
sleep 3 && \
/usr/local/bin/xray run -c /usr/local/etc/xray/config.json & \
sleep 2 && \
socat TCP-LISTEN:$PORT,fork TCP:127.0.0.1:8080 \
'