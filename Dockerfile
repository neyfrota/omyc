#
# we like ubuntu :)
FROM ubuntu:14.04
#NAME="Ubuntu"
#VERSION="16.04.1 LTS (Xenial Xerus)"
#ID=ubuntu
#ID_LIKE=debian
#PRETTY_NAME="Ubuntu 16.04.1 LTS"
#VERSION_ID="16.04"
#HOME_URL="http://www.ubuntu.com/"
#SUPPORT_URL="http://help.ubuntu.com/"
#BUG_REPORT_URL="http://bugs.launchpad.net/ubuntu/"
#UBUNTU_CODENAME=xenial
#
# our ID
MAINTAINER NICANDNEY <omyc@frota.net>
LABEL version="0.1"
LABEL description="Old man yells at cloud. https://omyc.github.io/"
#
# copy what we need
COPY omyc /omyc/
#
# all deploy inteligence lives at this script
RUN ["/bin/bash", "/omyc/bin/docker/build.sh"]
#
# 80/443 for webinterface. 22 for sftp. 55555 for btsync
EXPOSE 80 443 22 55555
#
# start all the magic
ENTRYPOINT ["/omyc/bin/docker/entrypoint.sh"]

