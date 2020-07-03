FROM centos:8

# ARG can be overwritten on build time using "docker build --build-arg name=value"
ARG CMK_VERSION="1.6.0p13"
ARG CMK_DOWNLOADNR="38"
ARG CMK_OS_VERSION="el8"

ENV CMK_SITE="mva"
ENV MAILHUB="undefined"
ENV DEFAULT_USERNAME="cmkadmin"
ENV DEFAULT_PASSWORD="omd"
ENV BCRYPT_ITERATION="18"

# Install required packages
RUN \
    yum -y install epel-release && \
    dnf --enablerepo=PowerTools install -y --nogpgcheck time \
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
        php-json \
        perl-Net-Ping \
        php \
        php-mbstring \
        php-pdo \
        php-gd \
        php-xml \
        rsync \
        uuid \
        xinetd \
        cronie \
        python3-ldap \
        freeradius-utils \
        libpcap \
        python3-reportlab \
        bind-utils \
        python3-imaging \
        poppler-utils \
        libgsf \
        rpm-build \
        python3-pyOpenSSL \
        fping \
        libmcrypt \
        which \
        mailx \
        openssh-clients \
        samba-client \
        rpcbind \
        postgresql-libs

# retrieve and install the check mk binaries
RUN rpm -ivh https://checkmk.de/support/${CMK_VERSION}/check-mk-raw-${CMK_VERSION}-${CMK_OS_VERSION}-${CMK_DOWNLOADNR}.x86_64.rpm

# Workaround for check_mk init script failing if /etc/fstab is either empty or does not exist
RUN echo " " > /etc/fstab

ADD bootstrap.sh /
ADD healthcheck.sh /

VOLUME [ "/opt/omd/sites" ]
EXPOSE 5000/tcp
HEALTHCHECK CMD /healthcheck.sh

WORKDIR /omd
CMD [ "/bootstrap.sh" ]

