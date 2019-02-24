FROM centos:7
Label MAINTAINER="Lionel H. <houssoli@gmail.com>"
ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
RUN yum -y update; yum clean all
RUN yum -y install openssh-server openssh-clients passwd sudo; yum clean all
RUN systemctl enable sshd.service
ADD ./start.sh /start.sh
ADD ./run.sh /run.sh
RUN mkdir /var/run/sshd
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
RUN chmod 755 /start.sh && chmod 755 /run.sh
RUN ./start.sh
VOLUME [ "/sys/fs/cgroup" ]
ENV AUTHORIZED_KEYS nil
EXPOSE 22
CMD ["/run.sh"]
