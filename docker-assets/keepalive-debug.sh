#!/bin/bash

#init.sh:   initializes environment needed for app (e.g. install NPM modules for app, etc)
#login.sh:  script runs once a telnet/ssh session is established + launches the app to remote

#chmod +x and dos2unix init.sh and login.sh
echo "keepalive.sh: chmod +x and dos2unix init.sh and login.sh"
touch /root/my/init.sh
chmod +x /root/my/init.sh
dos2unix /root/my/init.sh

touch /root/my/login.sh
chmod +x /root/my/login.sh
dos2unix /root/my/login.sh

#initialize app (e.g. compile, npm install, etc)
echo "keepalive.sh: exec /root/my/init.sh"
/root/my/init.sh

#launch telnet and SSH daemons
echo "keepalive.sh: starting Telnet..."
service xinetd restart
echo "keepalive.sh: Telnet started"

echo "keepalive.sh: starting SSH..."
/usr/sbin/sshd
echo "keepalive.sh: SSH started"