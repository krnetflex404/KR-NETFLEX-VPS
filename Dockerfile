FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install packages
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl \
    wget \
    nano \
    && mkdir /var/run/sshd

# Set root password
RUN echo 'root:root123' | chpasswd

# Allow root login
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Fix PAM issue
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

# Expose SSH port
EXPOSE 22

# Start SSH server
CMD ["/usr/sbin/sshd", "-D"]