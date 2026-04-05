FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install SSH
RUN apt update && apt install -y openssh-server && rm -rf /var/lib/apt/lists/*

# SSH setup
RUN mkdir /var/run/sshd

# Root password (change kar lena)
RUN echo 'root:123456' | chpasswd

# SSH config
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config

# Expose port
EXPOSE 2222

# Start SSH
CMD ["/usr/sbin/sshd", "-D"]