FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install packages
RUN apt update && apt install -y \
    curl unzip ca-certificates openssh-server && \
    rm -rf /var/lib/apt/lists/*

# Set root password
RUN echo "root:123456" | chpasswd

# SSH setup
RUN mkdir /var/run/sshd

# Change SSH port + enable root login
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#Port 22/Port 54809/' /etc/ssh/sshd_config

# Install Xray
RUN curl -L https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o xray.zip && \
    unzip xray.zip && \
    mv xray /usr/local/bin/ && \
    chmod +x /usr/local/bin/xray && \
    rm -rf xray.zip

RUN mkdir -p /etc/xray
COPY config.json /etc/xray/config.json

# Expose SSH port
EXPOSE 54809

# Start services
CMD service ssh start && \
    sed -i "s/PORT/${PORT}/g" /etc/xray/config.json && \
    xray -config /etc/xray/config.json