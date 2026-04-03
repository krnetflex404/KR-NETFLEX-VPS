FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ---------------- Install packages ----------------
RUN apt update && apt install -y \
    openssh-server \
    curl \
    wget \
    unzip \
    ca-certificates \
    iptables \
    iproute2 \
    net-tools \
    python3 \
    python3-pip \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

# ---------------- SSH ----------------
RUN mkdir /var/run/sshd
RUN echo 'root:123456' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config

# ---------------- Enable IP Forward ----------------
RUN echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# ---------------- Install Flask ----------------
RUN pip3 install flask

# ---------------- Mini AWS Panel ----------------
RUN mkdir /app

RUN cat << 'EOF' > /app/app.py
from flask import Flask, jsonify
import os, random

app = Flask(__name__)

@app.route("/")
def home():
    return "<h1>Mini AWS Panel 🚀</h1><br><a href=/create>Create Server</a>"

@app.route("/create")
def create():
    port = random.randint(20000,30000)
    name = f"user_{port}"

    os.system(f"docker run -d --name {name} -p {port}:22 ubuntu:22.04 bash -c \"apt update && apt install -y openssh-server && echo root:123456 | chpasswd && service ssh start && tail -f /dev/null\"")

    return jsonify({
        "ip": "metro.proxy.rlwy.net",
        "port": 34366,
        "user": "root",
        "pass": "123456"
    })

app.run(host="0.0.0.0", port=5000)
EOF

# ---------------- 3x-ui ----------------
RUN mkdir -p /usr/local/x-ui && \
    wget -q https://github.com/mhsanaei/3x-ui/releases/latest/download/x-ui-linux-amd64.tar.gz -O x-ui.tar.gz && \
    tar -xzf x-ui.tar.gz -C /usr/local/x-ui --strip-components=1 && \
    chmod +x /usr/local/x-ui/x-ui && \
    rm -f x-ui.tar.gz

# ---------------- Xray ----------------
RUN mkdir -p /usr/local/x-ui/bin && \
    wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -O xray.zip && \
    unzip -o xray.zip -d /usr/local/x-ui/bin/ && \
    find /usr/local/x-ui/bin -type f -name "xray" -exec mv {} /usr/local/x-ui/bin/xray-linux-amd64 \; && \
    chmod +x /usr/local/x-ui/bin/xray-linux-amd64 && \
    rm -f xray.zip

WORKDIR /usr/local/x-ui

# ---------------- Cloudflare ----------------
RUN wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

EXPOSE 80 2222 5000

# ---------------- START ----------------
CMD bash -c "\
sysctl -p && \
iptables -t nat -A POSTROUTING -j MASQUERADE && \
/usr/sbin/sshd -D -p 2222 & \
sleep 2 && \
/usr/local/x-ui/x-ui setting -port 80 && \
/usr/local/x-ui/x-ui & \
python3 /app/app.py & \
sleep 5 && \
cloudflared tunnel --no-autoupdate run --token eyJhIjoiNzkxNjk1NTNkZjA2OTQ3ODAyNzdlODFmYzhiZTM2MjgiLCJ0IjoiOWM0OTUzMzktMGE5OC00OTcxLTk4OGUtYjJlZmU5NDU4ZDJhIiwicyI6IllUQTNNV0kzT0RJdE5EVmxaQzAwT0RoakxUZzFNRE10TWpVNVlXRmtOV0ZsTXpKayJ9"