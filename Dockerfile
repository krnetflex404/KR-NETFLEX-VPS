FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ---------------- Install packages ----------------
RUN apt update && apt install -y \
    openssh-server \
    curl \
    wget \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ---------------- SSH Setup (UNCHANGED) ----------------
RUN mkdir /var/run/sshd
RUN echo 'root:123456' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config

# ---------------- x-ui Install ----------------
RUN mkdir -p /usr/local/x-ui && \
    wget -q https://github.com/vaxilu/x-ui/releases/latest/download/x-ui-linux-amd64.tar.gz -O x-ui.tar.gz && \
    tar -xzf x-ui.tar.gz -C /usr/local/x-ui --strip-components=1 && \
    chmod +x /usr/local/x-ui/x-ui && \
    rm -f x-ui.tar.gz

# ---------------- Xray Core ----------------
RUN mkdir -p /usr/local/x-ui/bin && \
    wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -O xray.zip && \
    unzip -o xray.zip -d /usr/local/x-ui/bin/ && \
    chmod +x /usr/local/x-ui/bin/xray && \
    rm -f xray.zip

# ---------------- Fix config ----------------
WORKDIR /usr/local/x-ui

RUN mkdir -p bin && \
    echo '{}' > bin/config.json && \
    chmod -R 755 /usr/local/x-ui

# ---------------- Railway Port ----------------
ENV PORT=8080

EXPOSE 8080 22

# ---------------- Start Services ----------------
CMD bash -c "\
echo 'nameserver 1.1.1.1' > /etc/resolv.conf && \
echo 'nameserver 8.8.8.8' >> /etc/resolv.conf && \

/usr/sbin/sshd -D -p 2222 & \
sleep 2 && \

/usr/local/x-ui/x-ui setting -port 8080 && \
/usr/local/x-ui/x-ui & \

tail -f /dev/null"