#!/bin/bash

# Put us in the right path
ABSPATH=`dirname $(readlink -f $0)`
cd $ABSPATH/
if [ ! -f dev.instance.run.sh ]
then
    echo "Oops. I do not know where i am :/"
    exit;
fi

# prepare dev instance data folder
mkdir dev.instance.data 2>/dev/null
if [ ! -d dev.instance.data ]
then
    echo "Oops. Fail create dev.instance.data :/"
    exit;
fi


# build and run in dev mode
cd docker
docker build -t omyc-dev .
docker run -i -t -p 22:22 -p 80:80 -p 443:443 -p 55555:55555 -v $ABSPATH/dev.instance.data/:/data -v $ABSPATH/docker/opt/omyc:/opt/omyc omyc-dev /opt/omyc/bin/docker.entrance.dev.sh


