FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

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

# ---------------- x-ui ----------------
RUN bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)

# ---------------- Start Script ----------------
RUN echo '#!/bin/bash

# Railway PORT fallback
PORT=${PORT:-3000}

# Fix nginx config dynamically
cat > /etc/nginx/sites-enabled/default <<EOF
server {
    listen 0.0.0.0:$PORT;

    location / {
        proxy_pass http://127.0.0.1:54321;
    }
}
EOF

# Start services
service ssh start
/usr/local/x-ui/x-ui &

# Wait a bit (important)
sleep 5

nginx -g "daemon off;"
' > /start.sh && chmod +x /start.sh

EXPOSE 3000

CMD ["/start.sh"]