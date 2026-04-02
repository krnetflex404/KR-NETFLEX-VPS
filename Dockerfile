FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV XRAY_LOCATION_ASSET=/usr/local/x-ui/bin
ENV PATH="/usr/local/x-ui/bin:${PATH}"

# Install packages
RUN apt update && apt install -y \
    openssh-server \
    curl \
    wget \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# SSH setup
RUN mkdir /var/run/sshd
RUN echo 'root:123456' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Install 3x-ui
RUN mkdir -p /usr/local/x-ui && \
    wget -q https://github.com/mhsanaei/3x-ui/releases/latest/download/x-ui-linux-amd64.tar.gz && \
    tar -xzf x-ui-linux-amd64.tar.gz -C /usr/local/x-ui --strip-components=1 && \
    chmod +x /usr/local/x-ui/x-ui && \
    rm -f x-ui-linux-amd64.tar.gz

# Install xray-core (SAFE download)
RUN mkdir -p /usr/local/x-ui/bin && \
    curl -L -o xray.zip https://github.com/XTLS/Xray-core/releases/download/v1.8.10/Xray-linux-64.zip && \
    unzip xray.zip -d /usr/local/x-ui/bin/ && \
    chmod +x /usr/local/x-ui/bin/xray && \
    mv /usr/local/x-ui/bin/xray /usr/local/x-ui/bin/xray-linux-amd64 && \
    ln -sf /usr/local/x-ui/bin/xray-linux-amd64 /usr/local/x-ui/bin/xray && \
    rm -f xray.zip

# Cloudflared
RUN curl -L -o /usr/local/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 && \
    chmod +x /usr/local/bin/cloudflared

EXPOSE 2222 2053

CMD bash -c "\
/usr/sbin/sshd -D -p 2222 & \
sleep 2 && \
cd /usr/local/x-ui && ./x-ui run & \
sleep 5 && \
cloudflared tunnel --no-autoupdate run --token eyJhIjoiNzkxNjk1NTNkZjA2OTQ3ODAyNzdlODFmYzhiZTM2MjgiLCJ0IjoiOWM0OTUzMzktMGE5OC00OTcxLTk4OGUtYjJlZmU5NDU4ZDJhIiwicyI6IllUQTNNV0kzT0RJdE5EVmxaQzAwT0RoakxUZzFNRE10TWpVNVlXRmtOV0ZsTXpKayJ9"