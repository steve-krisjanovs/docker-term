FROM debian:stretch

#container listens on telnet (23) and SSH (22) port
#--------------------------------------------------
EXPOSE 23
EXPOSE 22

#main environment variables
#keepalive.sh spins up two daemons (telnetd and ssh) 
#followed by an infinate keepalive loop to keep the container 
#running and is thus the script run in the dockerfile CMD
#------------------------------------------------------------
ENV ROOTDIR /root
WORKDIR ${ROOTDIR}
ENV STARTUP_SCRIPT keepalive.sh
ENV STARTUP_APP ${ROOTDIR}/${STARTUP_SCRIPT}
COPY ${STARTUP_SCRIPT} .

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y telnetd xinetd telnet openssh-server

#set up SSH access
#note - the sshd_config prevents users from accessing the container via sftp.
#Users can only connect via a bash session when connecting from ssh
#----------------------------------------------------------------------------
RUN mkdir /var/run/sshd
RUN echo root:password | /usr/sbin/chpasswd
COPY sshd_config /etc/ssh/sshd_config

#SSH login fix. Otherwise user is kicked off after login
#-------------------------------------------------------
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

#the customized telnet file below will skip login and launch a default app when connection is established.
#i.e. when connected via telnet, user will log in as root, bypassing user/password prompt,
#and launch a specified specified script in /etc/xinetd.d/telnet >> login-app.sh
#---------------------------------------------------------------------------------------------------
COPY telnet /etc/xinetd.d/telnet

#install git (in case git cloning your app into the container is preferred)
#--------------------------------------------------------------------------
RUN apt-get install -y git

#prep app directories (onr per language)
#---------------------------------------
#RUN mkdir -p ${ROOTDIR}/app/dos/c    
RUN mkdir -p ${ROOTDIR}/.dosemu/drive_c
RUN mkdir -p ${ROOTDIR}/app/python
RUN mkdir -p ${ROOTDIR}/app/nodejs
RUN mkdir -p ${ROOTDIR}/app/dotnetcore
RUN mkdir -p ${ROOTDIR}/app/powershellcore

#install dosemu (for legacy dos ANSI apps) - not working (Package 'dosemu' has no installation candidate)
#-----------------------------------------
#RUN apt-get update && apt-get install -y dosemu (doesn't work. get "Package 'dosemu' has no installation candidate")
RUN apt-get install -y wget
RUN apt-get install -y libasound2
RUN apt-get install -y libslang2
RUN apt-get install -y libsndfile1
RUN apt-get install -y libxxf86vm1
RUN apt-get install -y libsdl1.2debian
RUN apt-get install -y xfonts-utils
ENV DOSEMU_DEB dosemu_1.4.0.7+20130105+b028d3f-2+b1_amd64.deb
RUN wget -q http://http.us.debian.org/debian/pool/contrib/d/dosemu/${DOSEMU_DEB}
RUN dpkg -i ./${DOSEMU_DEB}
RUN rm ./${DOSEMU_DEB}

#install node.js 10.x LTS + typescript
#-------------------------------------
RUN apt-get install -y curl software-properties-common wget gnupg2
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g typescript

#install .net core 2.2 (debian 9 stretch)
#----------------------------------------
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.asc.gpg
RUN mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/
RUN wget -q https://packages.microsoft.com/config/debian/9/prod.list
RUN mv prod.list /etc/apt/sources.list.d/microsoft-prod.list
RUN chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg
RUN chown root:root /etc/apt/sources.list.d/microsoft-prod.list
RUN apt-get update
RUN apt-get install -y dotnet-sdk-2.2

#install python 2.7
#------------------
RUN apt-get install -y python2.7 python-pip

#install powershell core for debian 9
#------------------------------------
# Install system components
RUN apt-get update
RUN apt-get install curl gnupg apt-transport-https
# Import the public repository GPG keys
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
# Register the Microsoft Product feed
RUN sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/microsoft.list'
# Update the list of products
RUN apt-get update
# Install PowerShell
RUN apt-get install -y powershell

#----------------------------------------------------------------------------------------
#BEGIN INSTALL APP
#----------------------------------------------------------------------------------------
#   Copy over .bashrc, the console app you want to run, and any dependencies your app needs.
#   The workflow for what calls what is as follows when a user telnets or ssh's into the app:
#
#   ssh connect >> ssh login >> .bashrc >> login-app.sh >> myapp.py >> exit
#   OR...
#   telnet connect (login bypass) >> login-app.sh >> myapp.py >> exit
#
#   NOTE - blessed pip package is installed because myapp.py imports blessed for TUI support.
#   The code in this block should really be the only relevant pieces you need to modify.
#
#   File details
#   ------------
#   myapp.py: the "helloworld" terminal application in this demo
#   login-app.sh: this launches myapp.py). Do not remove or rename this file. Mods okay.
#   .bashrc: detects if the session is ssh. If so, then launch login-app.sh. Else exit
#
#   note - if you need to interactively shell into the container to troubleshoot, 
#   You cannot shell into a bash session since a bash session runs your terminal app then exits. 
#   docker run -it into the container using sh instead. 
#----------------------------------------------------------------------------------------
ENV SHELL_LOGIN_SCRIPT login-app.sh
ENV SHELL_LOGIN_PATH ${ROOTDIR}/${SHELL_LOGIN_SCRIPT}
COPY ${SHELL_LOGIN_SCRIPT} .
COPY .bashrc .

#copy over application demos
#---------------------------

#dosemu (doesn't work yet)
COPY app/dos/c/myapp.bat ${ROOTDIR}/.dosemu/drive_c/myapp.bat

#Python
COPY app/python/myapp.py ${ROOTDIR}/app/python/myapp.py
RUN pip install blessed

#node.js
COPY app/nodejs/myapp.js ${ROOTDIR}/app/nodejs/myapp.js
COPY app/nodejs/package.json ${ROOTDIR}/app/nodejs/package.json
WORKDIR ${ROOTDIR}/app/nodejs/
RUN npm install

#dotnet core
COPY app/dotnetcore/myapp.csproj ${ROOTDIR}/app/dotnetcore/myapp.csproj
COPY app/dotnetcore/myapp.cs ${ROOTDIR}/app/dotnetcore/myapp.cs
WORKDIR ${ROOTDIR}/app/dotnetcore
RUN dotnet build

#powershell core
COPY app/powershellcore/myapp.ps1 ${ROOTDIR}/app/powershellcore/myapp.ps1

#---------------------------------------------------------------------------------------
#END INSTALL APP
#---------------------------------------------------------------------------------------

WORKDIR ${ROOTDIR}
CMD "${STARTUP_APP}"