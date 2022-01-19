#!/bin/bash

# TODO: die if not inside docker instance
#
# create user.group at id 1000
groupadd -g 1000 omyc
useradd -u 1000 -g 1000 --no-create-home -s /bin/bash omyc

#
# update repo index
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y software-properties-common

# btsync now is local at project folder, so we update in sync with omyc
# #
# # install btsync
# add-apt-repository -y ppa:tuxpoldo/btsync
# apt-get update -y
# apt-get install -y btsync
# rm -f /etc/btsync/*.conf

#
# install webapp resources
apt-get install -y libmojolicious-perl libtimedate-perl apache2 php5 php5-cli libapache2-mod-php5 php5-gd php5-json php5-curl apache2-utils libjson-perl liburi-perl dnsutils curl
rm -f /etc/apache2/sites-enabled/*
ln -s /omyc/etc/sites-enabled.conf /etc/apache2/sites-enabled/omyc.conf
a2dismod status
a2enmod rewrite
a2enmod auth_basic
a2enmod authn_core
a2enmod authn_file
a2enmod authz_core
a2enmod authz_host
a2enmod authz_user
a2enmod php5
a2enmod ssl
a2enmod cgi
a2enmod include
a2enmod proxy
a2enmod proxy_http
a2enmod headers
rm -f /etc/apache2/conf-enabled/other-vhosts-access-log.conf
rm -f /etc/apache2/conf-enabled/localized-error-pages.conf
rm -f /etc/apache2/conf-enabled/serve-cgi-bin.conf
rm -f /etc/apache2/conf-enabled/security.conf
echo "ServerTokens Minimal" >> /etc/apache2/conf-enabled/security.conf
echo "ServerSignature Off" >> /etc/apache2/conf-enabled/security.conf
echo "TraceEnable Off" >> /etc/apache2/conf-enabled/security.conf
sed -i -e 's/export APACHE_RUN_USER=www-data/export APACHE_RUN_USER=omyc/' /etc/apache2/envvars
sed -i -e 's/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=omyc/' /etc/apache2/envvars
#
# install proftp
apt-get install -y proftpd openssh-server
rm -f /etc/proftpd/proftpd.conf
ln -s /omyc/etc/proftpd.conf /etc/proftpd/proftpd.conf
#
# clean the house
apt-get autoremove -y
apt-get autoclean -y
