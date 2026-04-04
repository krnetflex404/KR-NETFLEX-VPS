FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ---------------- Install packages ----------------
RUN apt update && apt install -y \
    curl \
    wget \
    unzip \
    ca-certificates \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# ---------------- Timezone ----------------
ENV TZ=Asia/Kolkata
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# ---------------- 3x-ui ----------------
RUN mkdir -p /usr/local/x-ui && \
    wget -q https://github.com/mhsanaei/3x-ui/releases/latest/download/x-ui-linux-amd64.tar.gz -O x-ui.tar.gz && \
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

# ---------------- Port ----------------
ENV PORT=8080
EXPOSE 8080

# ---------------- Start ----------------
CMD bash -c "\
echo 'nameserver 1.1.1.1' > /etc/resolv.conf && \
echo 'nameserver 8.8.8.8' >> /etc/resolv.conf && \

/usr/local/x-ui/x-ui setting -port $PORT && \
/usr/local/x-ui/x-ui & \

tail -f /dev/null"