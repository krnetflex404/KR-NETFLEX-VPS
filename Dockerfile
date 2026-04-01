FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    openssh-server \
    nginx

RUN mkdir /var/run/sshd
RUN echo 'root:123456' | chpasswd

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Simple webpage
RUN echo "KR NETFLIX VPS RUNNING" > /var/www/html/index.html

EXPOSE 80 2222

CMD service ssh start && nginx -g 'daemon off;'