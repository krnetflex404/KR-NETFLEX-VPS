FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install packages
RUN apt update && apt install -y \
    openssh-server \
    curl \
    wget \
    bash

# SSH setup
RUN mkdir /var/run/sshd
RUN echo 'root:123456' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Install x-ui (fixed method)
RUN curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh -o install.sh && \
    bash install.sh

# Install cloudflared
RUN wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# Expose panel port
EXPOSE 54321

# Start everything
CMD service ssh start && \
    /usr/local/x-ui/x-ui start && \
    cloudflared tunnel --no-autoupdate run --token eyJhIjoiNzkxNjk1NTNkZjA2OTQ3ODAyNzdlODFmYzhiZTM2MjgiLCJ0IjoiOWM0OTUzMzktMGE5OC00OTcxLTk4OGUtYjJlZmU5NDU4ZDJhIiwicyI6IllUQTNNV0kzT0RJdE5EVmxaQzAwT0RoakxUZzFNRE10TWpVNVlXRmtOV0ZsTXpKayJ9