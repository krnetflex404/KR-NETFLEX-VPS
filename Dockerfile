FROM ubuntu:22.04

RUN apt update && apt install -y openssh-server

RUN mkdir /var/run/sshd
RUN echo 'root:123456' | chpasswd

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

EXPOSE 80

CMD ["/usr/sbin/sshd","-D","-p","80"]