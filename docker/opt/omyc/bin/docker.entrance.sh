#!/bin/bash


# start omyc
/opt/omyc/bin/omyc.start

# sit and wait
echo "Show logs forever (in future we need some less noise and trash to filesystem)"
tail -f -n 0 /var/log/apache2/* /var/log/proftpd/* /var/log/api.server.log 

