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
ENV APPDIR /root
WORKDIR ${APPDIR}
ENV STARTUP_SCRIPT keepalive.sh
ENV STARTUP_APP ${APPDIR}/${STARTUP_SCRIPT}
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
ENV SHELL_LOGIN_PATH ${APPDIR}/${SHELL_LOGIN_SCRIPT}
COPY ${SHELL_LOGIN_SCRIPT} .
COPY .bashrc .
COPY app/myapp.py .
RUN pip install blessed
#---------------------------------------------------------------------------------------
#END INSTALL APP
#---------------------------------------------------------------------------------------

CMD "${STARTUP_APP}"