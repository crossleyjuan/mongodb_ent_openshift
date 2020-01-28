FROM centos:7

ENV SUMMARY="MongoDB NoSQL database server" \
    DESCRIPTION="MongoDB is a free and open-source \
cross-platform document-oriented database program. Classified as a NoSQL \
database program, MongoDB uses JSON-like documents with schemas. This \
container image contains programs to run mongod server."

ENV CONTAINER_SCRIPTS_PATH=/usr/share/mongod-scripts \
	MONGODB_DATADIR=/mongodb_data \
    MONGODB_LOGPATH=/mongodb_log \
    MONGODB_KEYFILE_PATH=/mongodb_data/keyfile

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="MongoDB 4.2" \
      io.openshift.expose-services="27017:mongodb" \
      io.openshift.tags="database,mongodb,mongodb-enterprise-42" \
      com.redhat.component="rh-mongodb42-container" \
      name="centos/mongodb-42-centos7" \
      usage="docker run -d -e MONGODB_ADMIN_PASSWORD=my_pass mongodb:latest" \
      version="1" \
      maintainer="MongoDB <juan.crossley@mongodb.com>"

COPY root /

#COPY mongodb-enterprise-server-4.2.2-1.el7.x86_64.rpm  /opt/mongodb-enterprise-server-4.2.2-1.el7.x86_64.rpm 
#COPY mongodb-enterprise-mongos-4.2.2-1.el7.x86_64.rpm /opt/mongodb-enterprise-mongos-4.2.2-1.el7.x86_64.rpm
#COPY mongodb-enterprise-tools-4.2.2-1.el7.x86_64.rpm /opt/mongodb-enterprise-tools-4.2.2-1.el7.x86_64.rpm
#COPY mongodb-enterprise-shell-4.2.2-1.el7.x86_64.rpm /opt/mongodb-enterprise-shell-4.2.2-1.el7.x86_64.rpm

ADD https://repo.mongodb.com/yum/redhat/7/mongodb-enterprise/4.2/x86_64/RPMS/mongodb-enterprise-server-4.2.2-1.el7.x86_64.rpm  /opt/mongodb-enterprise-server-4.2.2-1.el7.x86_64.rpm 
ADD https://repo.mongodb.com/yum/redhat/7/mongodb-enterprise/4.2/x86_64/RPMS/mongodb-enterprise-mongos-4.2.2-1.el7.x86_64.rpm /opt/mongodb-enterprise-mongos-4.2.2-1.el7.x86_64.rpm
ADD https://repo.mongodb.com/yum/redhat/7/mongodb-enterprise/4.2/x86_64/RPMS/mongodb-enterprise-tools-4.2.2-1.el7.x86_64.rpm /opt/mongodb-enterprise-tools-4.2.2-1.el7.x86_64.rpm
ADD https://repo.mongodb.com/yum/redhat/7/mongodb-enterprise/4.2/x86_64/RPMS/mongodb-enterprise-shell-4.2.2-1.el7.x86_64.rpm /opt/mongodb-enterprise-shell-4.2.2-1.el7.x86_64.rpm

RUN mkdir -p /mongodb_data && \ 
    mkdir -p /mongodb_log && \
    mkdir -p /var/run/mongodb && \
    chgrp -R 0 /var/run/mongodb && \
    chmod -R g+rwX /var/run/mongodb && \
    chgrp -R 0 /mongodb_data && \
    chmod -R g+rwX /mongodb_data && \
    chgrp -R 0 /mongodb_log && \
    chmod -R g+rwX /mongodb_log && \
    groupadd -g 1001 appuser && \
	useradd -r -u 1001 -g appuser appuser && \
    mkdir -p /home/appuser && \
    chgrp -R 0 /home/appuser && \
    chmod -R g+rwX /home/appuser && \
    chmod 755 /etc/init.d/disable-transparent-hugepages && \
    chkconfig --add disable-transparent-hugepages && \
    yum update -y && \
	yum install -y gettext bind-utils cyrus-sasl cyrus-sasl-gssapi cyrus-sasl-plain krb5-libs libcurl libpcap lm_sensors-libs net-snmp net-snmp-agent-libs openldap openssl rpm-libs tcp_wrappers-libs && \
    rpm -ivh /opt/mongodb-enterprise-server-4.2.2-1.el7.x86_64.rpm && \
    rpm -ivh /opt/mongodb-enterprise-shell-4.2.2-1.el7.x86_64.rpm && \
    rpm -ivh /opt/mongodb-enterprise-mongos-4.2.2-1.el7.x86_64.rpm && \
    rpm -ivh /opt/mongodb-enterprise-tools-4.2.2-1.el7.x86_64.rpm && \
    yum clean all && \
    chmod -R g+x /usr/bin/run_mongod && \
    chgrp -R 0 /etc/mongod.conf && \
    chmod -R g+rwX /etc/mongod.conf

USER user

ENV HOME /home/appuser

ENTRYPOINT ["container-entrypoint"]
CMD ["run_mongod"]
#CMD ["tail", "-f", "/dev/null"]

VOLUME ["/mongodb_data", "/mongodb_log", "/home/appuser"]
