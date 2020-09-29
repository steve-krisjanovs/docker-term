FROM debian:stretch

#container listens on telnet (23) and SSH (22) port
#--------------------------------------------------
EXPOSE 23
EXPOSE 22

#volume mount
#------------
VOLUME ["/root/my"]

#main environment variables
#keepalive.sh spins up two daemons (telnetd and ssh) 
#followed by an infinate keepalive loop to keep the container 
#running and is thus the script run in the dockerfile CMD
#------------------------------------------------------------
WORKDIR /root
COPY docker-assets/keepalive.sh .
COPY docker-assets/keepalive-debug.sh .
RUN chmod +x /root/keepalive.sh
RUN chmod +x /root/keepalive-debug.sh

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y telnetd xinetd telnet openssh-server
RUN apt-get install -y dos2unix

#set up SSH access
#note - the sshd_config prevents users from accessing the container via sftp.
#Users can only connect via a bash session when connecting from ssh
#----------------------------------------------------------------------------
RUN mkdir /var/run/sshd
COPY docker-assets/sshd_config /etc/ssh/sshd_config

#SSH login fix. Otherwise user is kicked off after login
#-------------------------------------------------------
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

#the customized telnet file below will skip login and launch a default app as root when connection is established.
#i.e. when connected via telnet, user will log in as root, bypassing user/password prompt,
#and launch a specified specified script in /etc/xinetd.d/telnet >> /root/my/login.sh
#---------------------------------------------------------------------------------------------------
COPY docker-assets/telnet /etc/xinetd.d/telnet
RUN dos2unix /etc/xinetd.d/telnet

#copy over .bashrc to retrict sftp access, etc.
#----------------------------------------------
COPY docker-assets/.bashrc .
RUN dos2unix /root/.bashrc

#make sure that keepalive.sh is in unix LF format
#------------------------------------------------
RUN dos2unix /root/keepalive.sh

#run keepalive app (starts Telnet + SSH)
#---------------------------------------
CMD "/root/keepalive.sh"