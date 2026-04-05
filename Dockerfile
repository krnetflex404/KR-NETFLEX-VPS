FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install SSH
RUN apt update && apt install -y openssh-server && rm -rf /var/lib/apt/lists/*

# SSH setup
RUN mkdir /var/run/sshd

# Root password set karo (change kar lena)
RUN echo 'root:123456' | chpasswd

# Root login enable
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Password auth enable
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Port change (Railway ke liye 2222 better rehta hai)
RUN sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config

# Expose port
EXPOSE 2222

# Run SSH
CMD ["/usr/sbin/sshd", "-D"]