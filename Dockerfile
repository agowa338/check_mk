FROM centos:7

# ARG can be overwritten on build time using "docker build --build-arg name=value"
ARG CMK_VERSION_ARG="1.5.0b7"
ARG CMK_DOWNLOADNR_ARG="38"
ARG CMK_SITE_ARG="mva"
ARG MAILHUB="undefined"
ARG DEFAULT_USERNAME="cmkadmin"
ARG DEFAULT_PASSWORD="omd"

# After Build the ENV vars are initialized with the value of there build argument.
ENV CMK_VERSION=${CMK_VERSION_ARG}
ENV CMK_DOWNLOADNR=${CMK_DOWNLOADNR_ARG}
ENV CMK_SITE=${CMK_SITE_ARG}
ENV MAILHUB=${MAILHUB}

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
        rpcbind

ADD    bootstrap.sh /opt/
ADD    redirector.sh /opt/

# retrieve and install the check mk binaries
RUN rpm -ivh https://mathias-kettner.de/support/${CMK_VERSION}/check-mk-raw-${CMK_VERSION}-el7-${CMK_DOWNLOADNR}.x86_64.rpm

# Creation of the site fails on creating tempfs, ignore it.
# Now turn tempfs off after creating the site
RUN omd create ${CMK_SITE} || \
    omd config ${CMK_SITE} set DEFAULT_GUI check_mk && \
    omd config ${CMK_SITE} set TMPFS off && \
    omd config ${CMK_SITE} set CRONTAB on && \
    omd config ${CMK_SITE} set APACHE_TCP_ADDR 0.0.0.0 && \
    omd config ${CMK_SITE} set APACHE_TCP_PORT 5000 && \
    htpasswd -b -m /omd/sites/${CMK_SITE}/etc/htpasswd ${DEFAULT_USERNAME} ${DEFAULT_PASSWORD} && \
    ln -s "/omd/sites/${CMK_SITE}/var/log/nagios.log" /var/log/nagios.log && \
    /opt/redirector.sh ${CMK_SITE} > /omd/sites/${CMK_SITE}/var/www/index.html

EXPOSE 5000/tcp
VOLUME [ "/opt/omd/sites/${CMK_SITE}/local", "/opt/omd/sites/${CMK_SITE}/etc/check_mk" ]
WORKDIR /omd
ENTRYPOINT ["/opt/bootstrap.sh"]
