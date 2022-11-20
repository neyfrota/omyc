#!/bin/bash

# ================================
# start
# ================================
#
echo "==============================================="
echo "Start OMYC"
echo "==============================================="




# ================================
# fix folders
# ================================

mkdir /data/ >/dev/null 2>/dev/null
mkdir /data/users/ >/dev/null 2>/dev/null
mkdir /data/settings/ >/dev/null 2>/dev/null
mkdir /data/settings/btsync >/dev/null 2>/dev/null
mkdir /data/settings/cert >/dev/null 2>/dev/null
touch /data/settings/sync.conf >/dev/null 2>/dev/null
touch /etc/btsync.conf >/dev/null 2>/dev/null
mkdir /data/cache/ >/dev/null 2>/dev/null
mkdir /data/cache/thumb/ >/dev/null 2>/dev/null

chown -f omyc.omyc /data/ >/dev/null 2>/dev/null
chown -f omyc.omyc /data/users/ >/dev/null 2>/dev/null
chown -Rf omyc.omyc /data/settings/ >/dev/null 2>/dev/null
chown -Rf omyc.omyc /data/settings/btsync >/dev/null 2>/dev/null
chown -Rf omyc.omyc /data/settings/cert >/dev/null 2>/dev/null
chown -f omyc.omyc /data/settings/sync.conf >/dev/null 2>/dev/null
chown -f omyc.omyc /etc/btsync.conf >/dev/null 2>/dev/null
chown -f omyc.omyc /data/cache/ >/dev/null 2>/dev/null
chown -f omyc.omyc /data/cache/thumb/ >/dev/null 2>/dev/null

chmod -f a-rwx,a+rX,u+w /data/ >/dev/null 2>/dev/null
chmod -f a-rwx,a+rX,u+w /data/users/ >/dev/null 2>/dev/null
chmod -Rf a-rwx,u+rwX /data/settings/ >/dev/null 2>/dev/null
chmod -Rf a-rwx,u+rwX /data/settings/btsync >/dev/null 2>/dev/null
chmod -Rf a-rwx,u+rwX /data/settings/cert >/dev/null 2>/dev/null
chmod -f a-rwx,u+rw /data/settings/sync.conf >/dev/null 2>/dev/null
chmod -f a-rwx,u+rw /etc/btsync.conf >/dev/null 2>/dev/null
chmod -f a-rwx,a+rX,u+w /data/cache/ >/dev/null 2>/dev/null
chmod -f a-rwx,a+rX,u+w /data/cache/thumb/ >/dev/null 2>/dev/null

chmod a+rw /dev/null



# ================================
# if no cert, create cert
# ================================
if [ ! -e /data/settings/cert/active.crt ]; then
    cat /etc/ssl/certs/ssl-cert-snakeoil.pem > /data/settings/cert/active.crt
    cat /etc/ssl/private/ssl-cert-snakeoil.key > /data/settings/cert/active.key
    echo "-----BEGIN CERTIFICATE-----" > /data/settings/cert/active.ca
    echo "-----END CERTIFICATE-----" >> /data/settings/cert/active.ca
    chown -Rf omyc.omyc /data/settings/cert >/dev/null 2>/dev/null
    chmod -Rf a-rwx,u+rwX /data/settings/cert >/dev/null 2>/dev/null
fi



# ================================
# if no users, create admin
# ================================
if [ ! -e /data/settings/users.sftp ]; then
	echo "No users. Create user admin/admin"
    #
	mkdir /data/users/admin >/dev/null 2>/dev/null
    chown -f omyc.omyc /data/users/admin/ >/dev/null 2>/dev/null
    chmod -f a-rwx,u+rwX /data/users/admin/ >/dev/null 2>/dev/null
    #
	touch /data/settings/users.web >/dev/null 2>/dev/null
	touch /data/settings/users.sftp >/dev/null 2>/dev/null
	touch /data/settings/groups.web >/dev/null 2>/dev/null
	touch /data/settings/groups.sftp >/dev/null 2>/dev/null
    #
	echo "admin"| /usr/sbin/ftpasswd --file /data/settings/users.sftp --passwd --name admin --home /data/users/admin/ --shell /bin/false --uid 1000 --gid 1000 --stdin  >/dev/null 2>/dev/null
	htpasswd -b /data/settings/users.web admin admin >/dev/null 2>/dev/null
    echo "admin:admin" > /data/settings/groups.web
    #
    chown -Rf omyc.omyc /data/settings/ >/dev/null 2>/dev/null
    chmod -f a-rwx,u+rwX /data/settings/ >/dev/null 2>/dev/null
    #
fi



# ================================
# setup logs
# ================================
rm -f /var/log/api.server.log  >/dev/null 2>/dev/null
rm -f /var/log/systemCommands.log  >/dev/null 2>/dev/null
rm -f /var/log/apache2/access.log  >/dev/null 2>/dev/null
rm -f /var/log/apache2/error.log  >/dev/null 2>/dev/null
rm -f /var/log/proftpd/controls.log  >/dev/null 2>/dev/null
rm -f /var/log/proftpd/proftpd.log  >/dev/null 2>/dev/null
rm -f /var/log/apache2/other_vhosts_access.log >/dev/null 2>/dev/null
ln -s /dev/null /var/log/apache2/other_vhosts_access.log >/dev/null 2>/dev/null
if [ "$development" = "true" ]; then
    echo "Prepare log files for debug"
	touch /var/log/systemCommands.log  >/dev/null 2>/dev/null
    touch /var/log/api.server.log >/dev/null 2>/dev/null
    touch /var/log/apache2/access.log >/dev/null 2>/dev/null
    touch /var/log/apache2/error.log >/dev/null 2>/dev/null
    touch /var/log/proftpd/controls.log >/dev/null 2>/dev/null
    touch /var/log/proftpd/proftpd.log >/dev/null 2>/dev/null
else
    # not debug. Lets point all logs to /dev/null so we create less garbage at fs
	ln -s /dev/null /var/log/systemCommands.log  >/dev/null 2>/dev/null
    ln -s /dev/null /var/log/api.server.log >/dev/null 2>/dev/null
    ln -s /dev/null /var/log/apache2/access.log >/dev/null 2>/dev/null
    ln -s /dev/null /var/log/apache2/error.log >/dev/null 2>/dev/null
    # proftp complain link to devnull... we need mute logs in different way
    #ln -s /dev/null /var/log/proftpd/controls.log >/dev/null 2>/dev/null
    #ln -s /dev/null /var/log/proftpd/proftpd.log >/dev/null 2>/dev/null
fi
rm -f /tmp/systemCommands  >/dev/null 2>/dev/null
touch /tmp/systemCommands  >/dev/null 2>/dev/null
chown -Rf omyc.omyc /tmp/systemCommands >/dev/null 2>/dev/null
chown -Rf omyc.omyc /var/log/systemCommands.log >/dev/null 2>/dev/null
chown -Rf omyc.omyc /var/log/api.server.log >/dev/null 2>/dev/null
chown -Rf omyc.omyc /var/log/api.server.log >/dev/null 2>/dev/null
chown -Rf omyc.omyc /var/log/apache2/ >/dev/null 2>/dev/null
chown -Rf omyc.omyc /var/log/proftpd/ >/dev/null 2>/dev/null
chmod -Rf a-rwx,a+rX,u+w /tmp/systemCommands >/dev/null 2>/dev/null
chmod -Rf a-rwx,a+rX,u+w /var/log/systemCommands.log  >/dev/null 2>/dev/null
chmod -Rf a-rwx,a+rX,u+w /var/log/api.server.log >/dev/null 2>/dev/null
chmod -Rf a-rwx,a+rX,u+w /var/log/apache2/ >/dev/null 2>/dev/null
chmod -Rf a-rwx,a+rX,u+w /var/log/proftpd/ >/dev/null 2>/dev/null




# ================================
# setup cron
# ================================
echo "* * * * * /omyc/bin/systemCommands/runQueue >/var/log/systemCommands.log 2>/var/log/systemCommands.log " > /tmp/mycron 2>/dev/null
echo "30 * * * * /omyc/bin/systemCommands/command.checkSystemServices >/dev/null 2>/dev/null " >> /tmp/mycron 2>/dev/null
crontab /tmp/mycron >/dev/null 2>/dev/null
rm /tmp/mycron >/dev/null 2>/dev/null
killall cron  >/dev/null 2>/dev/null
rm -f /var/run/crond.pid  >/dev/null 2>/dev/null



# ================================
# start services
# ================================
if [ "$development" = "true" ]; then
    echo "Start services in development mode"
	/omyc/bin/systemCommands/command.updateBtsyncFiles
	/omyc/bin/systemCommands/command.restartBtsync
	/etc/init.d/apache2 restart
	/etc/init.d/proftpd restart
	/usr/bin/sudo -u omyc /usr/bin/morbo -w /omyc/bin/api.server.pl -w /omyc/lib/ -v -l http://127.0.0.1:8080 /omyc/bin/api.server.pl  >>/var/log/api.server.log 2>>/var/log/api.server.log &
	cron -f  >/dev/null 2>/dev/null &
else
    echo "Start services in production mode"
	/omyc/bin/systemCommands/command.updateBtsyncFiles
	/omyc/bin/systemCommands/command.restartBtsync
	/etc/init.d/apache2 restart
	/etc/init.d/proftpd restart
	/usr/bin/sudo -u omyc /usr/bin/morbo -l http://127.0.0.1:8080 /omyc/bin/api.server.pl  >>/dev/null 2>>/dev/null &
	cron -f  >/dev/null 2>/dev/null &
fi



# ================================
# keep instance up
# ================================
echo "Show logs forever"
chmod a+rw /dev/null
tail -f -n 0 /var/log/apache2/* /var/log/proftpd/* /var/log/api.server.log /var/log/api.server.log /var/log/systemCommands.log  /tmp/systemCommands