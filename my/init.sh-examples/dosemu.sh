#!/bin/sh

#install dosemu (for legacy dos ANSI apps)
#-----------------------------------------
apt-get install -y wget
apt-get install -y libasound2
apt-get install -y libslang2
apt-get install -y libsndfile1
apt-get install -y libxxf86vm1
apt-get install -y libsdl1.2debian
apt-get install -y xfonts-utils
export DOSEMU_DEB=dosemu_1.4.0.7+20130105+b028d3f-2+b1_amd64.deb
wget -q http://http.us.debian.org/debian/pool/contrib/d/dosemu/$DOSEMU_DEB
dpkg -i ./$DOSEMU_DEB
rm ./$DOSEMU_DEB