FROM debian:11-slim
LABEL description="Old man yells at cloud. https://omyc.github.io/"
COPY omyc /omyc/
RUN ["/bin/bash", "/omyc/bin/docker/build.sh"]
EXPOSE 80 443 22 55555
ENTRYPOINT ["/omyc/bin/docker/entrypoint.sh"]

