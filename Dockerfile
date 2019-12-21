FROM centos:7

# ARG can be overwritten on build time using "docker build --build-arg name=value"
ARG CMK_VERSION="1.6.0b7"
ARG CMK_DOWNLOADNR="38"
ARG CMK_OS_VERSION="el7"

ENV CMK_SITE="mva"
ENV MAILHUB="undefined"
ENV DEFAULT_USERNAME="cmkadmin"
ENV DEFAULT_PASSWORD="omd"
ENV BCRYPT_ITERATION="18"

# Install required packages
RUN \
    yum -y install epel-release && \
    yum install -y --nogpgcheck time \
        traceroute \
        dialog \
        fping \
        graphviz \
        graphviz-gd \
        httpd \
        libevent \
        libdbi \
        libmcrypt \
        libtool-ltdl \
        mod_fcgid \
        mariadb-server \
        net-snmp \
        net-snmp-utils \
        pango \
        patch \
        perl-Net-SNMP \
        perl-Locale-Maketext-Simple \
        perl-IO-Zlib \
        php \
        php-mbstring \
        php-pdo \
        php-gd \
        php-xml \
        rsync \
        uuid \
        xinetd \
        cronie \
        python-ldap \
        freeradius-utils \
        libpcap \
        python-reportlab \
        bind-utils \
        python-imaging \
        poppler-utils \
        libgsf \
        rpm-build \
        pyOpenSSL \
        fping \
        libmcrypt \
        perl-Net-SNMP \
        which \
        ssmtp \
        mailx \
        openssh-clients \
        samba-client \
        rpcbind \
        postgresql-libs

# retrieve and install the check mk binaries
RUN rpm -ivh https://checkmk.com/support/${CMK_VERSION}/check-mk-raw-${CMK_VERSION}-${CMK_OS_VERSION}-${CMK_DOWNLOADNR}.x86_64.rpm

# Workaround for check_mk init script failing if /etc/fstab is either empty or does not exist
RUN echo " " > /etc/fstab

RUN touch /etc/ssmtp/ssmtp.conf && \
    chmod 640 /etc/ssmtp/ssmtp.conf && \
    chown root:mail /etc/ssmtp/ssmtp.conf

ADD bootstrap.sh /
ADD healthcheck.sh /

VOLUME [ "/opt/omd/sites" ]
EXPOSE 5000/tcp
HEALTHCHECK CMD /healthcheck.sh

WORKDIR /omd
CMD [ "/bootstrap.sh" ]
