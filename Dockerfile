FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install packages
RUN apt update && apt install -y \
    openssh-server \
    curl \
    wget \
    bash \
    ca-certificates

# SSH setup
RUN mkdir /var/run/sshd
RUN echo 'root:123456' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Install 3x-ui
RUN curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh -o install.sh && \
    bash install.sh

# ✅ ADD THIS BELOW (xray fix)
RUN apt update && apt install -y unzip && \
    mkdir -p /usr/local/x-ui/bin && \
    wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -O xray.zip && \
    unzip xray.zip -d /usr/local/x-ui/bin/ && \
    mv /usr/local/x-ui/bin/xray /usr/local/x-ui/bin/xray-linux-amd64 && \
    chmod +x /usr/local/x-ui/bin/xray-linux-amd64 && \
    rm -f xray.zip

# Install cloudflared
RUN wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# Railway port
ENV PORT=54321
EXPOSE 54321

# Start everything (FIXED)
CMD bash -c "\
service ssh start && \
/usr/local/x-ui/x-ui setting -port $PORT -username admin -password admin && \
/usr/local/x-ui/x-ui && \
cloudflared tunnel --no-autoupdate run --token eyJhIjoiNzkxNjk1NTNkZjA2OTQ3ODAyNzdlODFmYzhiZTM2MjgiLCJ0IjoiOWM0OTUzMzktMGE5OC00OTcxLTk4OGUtYjJlZmU5NDU4ZDJhIiwicyI6IllUQTNNV0kzT0RJdE5EVmxaQzAwT0RoakxUZzFNRE10TWpVNVlXRmtOV0ZsTXpKayJ9"