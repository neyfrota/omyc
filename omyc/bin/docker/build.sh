#!/bin/bash
echo "enter bin/docker/build.sh"
# TODO: die if not inside docker instance


echo "Create system user"
groupadd -g 1000 omyc
useradd -u 1000 -g 1000 --no-create-home -s /bin/bash omyc

#
# update repo index
echo "Update/upgrade system"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y software-properties-common sudo 
apt-get install -y libmojolicious-perl libtimedate-perl libjson-perl liburi-perl 
apt-get install -y dnsutils curl
apt-get install -y apache2 apache2-utils 
#apt-get install -y php5 php5-cli libapache2-mod-php5 php5-gd php5-json php5-curl 
apt-get install -y php php-cli libapache2-mod-php php-gd php-json php-curl 
apt-get install -y proftpd openssh-server



# btsync now is local at project folder, so we update in sync with omyc
echo "Install resilio sync"
# add-apt-repository -y ppa:tuxpoldo/btsync
# apt-get update -y
# apt-get install -y btsync
# rm -f /etc/btsync/*.conf


#
echo "Configure apache"
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

echo "Configure proftpd"
rm -f /etc/proftpd/proftpd.conf
ln -s /omyc/etc/proftpd/proftpd.conf /etc/proftpd/proftpd.conf

echo "Clean system"
apt-get autoremove -y
apt-get autoclean -y