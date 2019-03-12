#!/bin/sh

export HOME=/root

#below is a demo of each of the console apps in action
#-----------------------------------------------------

#######################
#EXAMPLE 1) run dos app
#######################
export _layout=us
dosemu -t /root/.dosemu/drive_c/myapp.bat

##########################
#EXAMPLE 2) run python app
##########################
cd /root/app/python
python myapp.py

###########################
#EXAMPLE 3) run node.js app
###########################
cd /root/app/nodejs
node myapp.js

###########################
#EXAMPLE 4) dotnet core app
###########################
export DOTNET_CLI_HOME=/root
cd /root/app/dotnetcore
dotnet run

######################################
#EXAMPLE 5) launch powershell core app
######################################
cd /root/app/powershellcore
clear
pwsh -File ./myapp.ps1

#clear
echo "Program completed. Exiting in 5 seconds..."
sleep 5s
#very important to have an exit line, so the user isn't retured to a bash shell
exit