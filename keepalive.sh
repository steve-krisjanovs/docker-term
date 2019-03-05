#!/bin/sh

#launch telnet and SSH daemons
echo "Container started. Listening for incoming telnet and ssh connections..."
service xinetd restart
/usr/sbin/sshd -D
while :; do sleep 1; done