FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ---------------- Install packages ----------------
RUN apt update && apt install -y \
    openssh-server \
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

# ---------------- SSH ----------------
RUN mkdir /var/run/sshd
RUN echo 'root:123456' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config

# ---------------- Install 3x-ui (non-interactive fix) ----------------
RUN curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh | bash -s -- -y

# ---------------- Railway Port ----------------
ENV PORT=8080

EXPOSE 8080 22

# ---------------- Start ----------------
CMD bash -c "\
echo 'nameserver 1.1.1.1' > /etc/resolv.conf && \
echo 'nameserver 8.8.8.8' >> /etc/resolv.conf && \

/usr/sbin/sshd -D -p 2222 & \
sleep 3 && \

x-ui setting -port 8080 && \
/usr/local/x-ui/x-ui & \

tail -f /dev/null"