#!/bin/bash

echo "==============================================="
echo "Start omyc in development mode."

# start omyc
/opt/omyc/bin/omyc.start debug

echo "If docker ports expose are right, you can web access https://<YOUR_IP> or https://127.0.0.1";
echo "If docker ports expose are right, you can sftp <YOUR_IP> or 127.0.0.1";

# print internal docker ip in case port forward is not active/possible
_IP=$(hostname -I) || true
if [ "$_IP" ]; then
  printf "You can also web access https://%s (only at host)\n" "$_IP"
  printf "You can also sftp %s (only at host)\n" "$_IP"
fi

# print some help
echo "This console is now root at this OMYC development instance. Leave this console open."
echo "You can play with ./opt/omyc/ folder at host to program (dev instance use this external folder at host instead internal one)";
echo "You can \"tail -f /var/log/api.server.log /var/log/apache2/* /var/log/proftpd/*\" here for valuable hints"
echo "Type exit to terminate this console and stop this OMYC development instance."
echo "==============================================="
/bin/bash



