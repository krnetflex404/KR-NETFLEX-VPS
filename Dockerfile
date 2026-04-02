FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install packages
RUN apt update && apt install -y \
    openssh-server \
    curl \
    wget \
    unzip \
    bash \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# SSH setup
RUN mkdir /var/run/sshd
RUN echo 'root:123456' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Install 3x-ui
RUN mkdir -p /usr/local/x-ui && \
    wget https://github.com/mhsanaei/3x-ui/releases/latest/download/x-ui-linux-amd64.tar.gz -O x-ui.tar.gz && \
    tar -xzf x-ui.tar.gz -C /usr/local/x-ui --strip-components=1 && \
    chmod +x /usr/local/x-ui/x-ui && \
    rm -f x-ui.tar.gz

# Install xray-core (FINAL FIX)
RUN mkdir -p /usr/local/x-ui/bin && \
    wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -O xray.zip && \
    unzip xray.zip -d /usr/local/x-ui/bin/ && \
    mv /usr/local/x-ui/bin/xray /usr/local/x-ui/bin/xray-linux-amd64 && \
    chmod +x /usr/local/x-ui/bin/xray-linux-amd64 && \
    rm -f xray.zip && \
    chmod -R 755 /usr/local/x-ui

# Cloudflared
RUN wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

EXPOSE 2222 2053

CMD bash -c "\
/usr/sbin/sshd -D -p 2222 & \
sleep 3 && \
cd /usr/local/x-ui && ./x-ui start && \
sleep 5 && \
cloudflared tunnel --no-autoupdate run --token eyJhIjoiNzkxNjk1NTNkZjA2OTQ3ODAyNzdlODFmYzhiZTM2MjgiLCJ0IjoiOWM0OTUzMzktMGE5OC00OTcxLTk4OGUtYjJlZmU5NDU4ZDJhIiwicyI6IllUQTNNV0kzT0RJdE5EVmxaQzAwT0RoakxUZzFNRE10TWpVNVlXRmtOV0ZsTXpKayJ9"