#
# we like ubuntu :)
FROM ubuntu
#
# our ID
MAINTAINER Ney Frota <omyc@frota.net>
LABEL version="1.0"
LABEL description="Old man yells at cloud. Minimalist cloud service"

#
# copy what we need
COPY opt/omyc /opt/omyc/
COPY Dockerfile.sh /tmp/Dockerfile.sh
#
# all deploy inteligence lives at this script
RUN ["/bin/bash", "/tmp/Dockerfile.sh"]
#
# 80/443 the webinterface. 22 is our sftp. 55555 is our btsync
EXPOSE 80 443 22 55555
#
# start all the magic
CMD ["/opt/omyc/bin/docker.entrance.sh"]
