FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y curl unzip ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o xray.zip && \
    unzip xray.zip && \
    mv xray /usr/local/bin/ && \
    chmod +x /usr/local/bin/xray && \
    rm -rf xray.zip

RUN mkdir -p /etc/xray

COPY config.json /etc/xray/config.json

CMD sed -i "s/PORT/${PORT}/g" /etc/xray/config.json && xray -config /etc/xray/config.json