#!/bin/bash


#
# create user.group at id 1000
groupadd -g 1000 omyc
useradd -u 1000 -g 1000 --no-create-home -s /bin/bash omyc

#
# update repo index
export DEBIAN_FRONTEND=noninteractive
apt-get update -y

# #
# # install btsync
# # btsync now is local at project folder, so we update in sync with omyc
# apt-get install -y software-properties-common
# add-apt-repository -y ppa:tuxpoldo/btsync
# apt-get update -y
# apt-get install -y btsync
# rm -f /etc/btsync/*.confproftpd-mod-vroot

#
# install packages
apt-get install -y libmojolicious-perl libtimedate-perl libjson-perl liburi-perl
apt-get install -y apache2-utils apache2 
apt-get install -y dnsutils curl
apt-get install -y php php-cli libapache2-mod-php php-gd php-json php-curl
apt-get install -y proftpd openssh-server proftpd-mod-crypto
# in case you need human interaction:
# apt-get install -y net-tools iputils-ping vim curl dnsutils


#
# config proftp
ln -s /omyc/etc/proftpd/conf.d.conf /etc/proftpd/conf.d/omyc.conf
sed -i -e 's/User proftpd/User omyc/' /etc/proftpd/proftpd.conf
sed -i -e 's/Group nogroup/Group omyc/' /etc/proftpd/proftpd.conf

#
# config apache
rm -f /etc/apache2/sites-enabled/*
ln -s /omyc/etc/apache2/sites-enabled.conf /etc/apache2/sites-enabled/omyc.conf
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
# clean the house
apt-get autoremove -y
apt-get autoclean -y
