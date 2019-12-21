#!/bin/bash

set -e

cat >/etc/ssmtp/ssmtp.conf <<CONFIG
root=root
mailhub=${MAILHUB}
FromLineOverride=YES
CONFIG

# By default check_mk is only listening on the loopback interface
omd create ${CMK_SITE}
omd config ${CMK_SITE} set APACHE_TCP_ADDR 0.0.0.0
mkdir -p /omd/sites/${CMK_SITE}/tmp/pnp4nagios/run
mkdir -p /omd/sites/${CMK_SITE}/tmp/nagios
mkdir -p /omd/sites/${CMK_SITE}/tmp/nagios/tmp
mkdir -p /omd/sites/${CMK_SITE}/tmp/lock
mkdir -p /omd/sites/${CMK_SITE}/tmp/nagios/checkresults
chown -R ${CMK_SITE}:${CMK_SITE} /omd/sites/${CMK_SITE}/tmp
ln -s "/omd/sites/${CMK_SITE}/var/log/nagios.log" /var/log/nagios.log

# Set htpasswd
htpasswd -bv /omd/sites/${CMK_SITE}/etc/htpasswd ${DEFAULT_USERNAME} ${DEFAULT_PASSWORD} 2>/dev/null || htpasswd -bBC ${BCRYPT_ITERATION} /omd/sites/${CMK_SITE}/etc/htpasswd ${DEFAULT_USERNAME} ${DEFAULT_PASSWORD} 2>/dev/null || htpasswd -bcBC ${BCRYPT_ITERATION} /omd/sites/${CMK_SITE}/etc/htpasswd ${DEFAULT_USERNAME} ${DEFAULT_PASSWORD}

# Add html redirect
echo '<html><head><title>Redirect</title><meta http-equiv="Refresh" content="0; url=/__DIR__/check_mk/" /></head><body><p>Please start here: <a href="/__DIR__/check_mk/">/__DIR__/check_mk/</a></p></body></html>' | sed "s/__DIR__/${CMK_SITE}/g" > /omd/sites/${CMK_SITE}/var/www/index.html

# Upgrade sites to latest check_mk
omd update mva 2>&1 || [ $? -eq 1 ]

# Start check_mk
omd start

exec tail -f /var/log/nagios.log
