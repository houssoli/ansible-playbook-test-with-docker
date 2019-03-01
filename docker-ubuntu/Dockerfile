FROM ubuntu:18.04

ENV container docker

# Don't start any optional services except for the few we need.
RUN find /etc/systemd/system \
    /lib/systemd/system \
    -path '*.wants/*' \
    -not -name '*journald*' \
    -not -name '*systemd-tmpfiles*' \
    -not -name '*systemd-user-sessions*' \
    -exec rm \{} \;
RUN apt-get update && \
    apt-get install -y \
    dbus git curl openssh-server openssh-client passwd sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN systemctl set-default multi-user.target
#RUN systemctl enable sshd.service
COPY ./nsenter/setup /sbin/
COPY ./start.sh /start.sh
COPY ./run.sh /run.sh
RUN mkdir /var/run/sshd
#RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
RUN chmod 755 /sbin/setup && chmod 755 /start.sh && chmod 755 /run.sh
RUN ./start.sh
VOLUME [ "/sys/fs/cgroup" ]
ENV AUTHORIZED_KEYS nil
EXPOSE 22

STOPSIGNAL SIGRTMIN+3

# Workaround for docker/docker#27202, technique based on comments from docker/docker#9212
CMD ["/bin/bash", "-c", "exec /sbin/init --log-target=journal 3>&1"]
