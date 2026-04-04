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

# ---------------- Timezone fix ----------------
ENV TZ=Asia/Kolkata
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# ---------------- SSH Setup (UNCHANGED) ----------------
RUN mkdir /var/run/sshd
RUN echo 'root:123456' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config

# ---------------- Install 3x-ui ----------------
RUN bash -c "$(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)"

# ---------------- Railway Port ----------------
ENV PORT=8080

EXPOSE 8080 22

# ---------------- Start Services ----------------
CMD bash -c "\
echo 'nameserver 1.1.1.1' > /etc/resolv.conf && \
echo 'nameserver 8.8.8.8' >> /etc/resolv.conf && \

/usr/sbin/sshd -D -p 2222 & \
sleep 3 && \

x-ui setting -port 8080 && \
x-ui start && \

tail -f /dev/null"