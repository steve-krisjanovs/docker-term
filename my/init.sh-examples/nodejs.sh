#!/bin/sh

#install node.js 10.x LTS + typescript
#-------------------------------------
apt-get install -y curl software-properties-common wget gnupg2
curl -sL https://deb.nodesource.com/setup_10.x | bash -
apt-get install -y nodejs
npm install -g typescript

#download modules for node app
echo "installing node modules needed for /root/my/app/nodejs/"
cd /root/my/app/nodejs
npm install

#npm install finished
cd /root