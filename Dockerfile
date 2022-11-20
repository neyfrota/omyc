FROM ubuntu:16.04
# i want this : ) FROM debian:11-slim
LABEL description="Old man yells at cloud"
COPY omyc /omyc/
RUN ["/bin/bash", "/omyc/bin/docker/build.sh"]
EXPOSE 80 443 22 55555
ENTRYPOINT ["/omyc/bin/docker/entrypoint.sh"]

