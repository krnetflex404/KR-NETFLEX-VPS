FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt update && apt install -y \
    openssh-server \
    curl \
    wget \
    unzip \
    nginx \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ---------------- SSH ----------------
RUN mkdir /var/run/sshd
RUN echo 'root:123456' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# ---------------- Xray ----------------
RUN wget -O xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip xray.zip && \
    mv xray /usr/local/bin/ && \
    chmod +x /usr/local/bin/xray && \
    rm -rf xray.zip

# ---------------- x-ui Panel ----------------
RUN bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)

# ---------------- Nginx Config (FIXED) ----------------
RUN rm /etc/nginx/sites-enabled/default
RUN echo '
server {
    listen 0.0.0.0:$PORT;

    location / {
        proxy_pass http://127.0.0.1:54321;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /vless {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:10000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
' > /etc/nginx/sites-enabled/default

# ---------------- Startup Script (FIXED) ----------------
RUN echo '#!/bin/bash

# Start SSH (background)
service ssh start

# Start x-ui (background)
/usr/local/x-ui/x-ui &

# Start nginx (foreground - IMPORTANT)
nginx -g "daemon off;"
' > /start.sh && chmod +x /start.sh

EXPOSE 3000

CMD ["/start.sh"]