#!/bin/bash

# Create SSMTP config
CFGFILE=/etc/ssmtp/ssmtp.conf

cat >$CFGFILE <<CONFIG
root=root
mailhub=${MAILHUB}
FromLineOverride=YES
CONFIG

chmod 640 $CFGFILE
chown root:mail $CFGFILE

# Create temp directories
mkdir -p /omd/sites/${CMK_SITE}/tmp/pnp4nagios/run
mkdir -p /omd/sites/${CMK_SITE}/tmp/nagios
mkdir -p /omd/sites/${CMK_SITE}/tmp/nagios/tmp
mkdir -p /omd/sites/${CMK_SITE}/tmp/lock
mkdir -p /omd/sites/${CMK_SITE}/tmp/nagios/checkresults
chown -R ${CMK_SITE}:${CMK_SITE} /omd/sites/${CMK_SITE}/tmp

# Start cron daemon
/usr/sbin/crond

# Start check_mk
omd start && tail -f /var/log/nagios.log
