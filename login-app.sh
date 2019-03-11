#!/bin/sh

#######################
#EXAMPLE 1) run dos app
#######################
#mount dosbox C drive (comment this out if you don't need it)
#(doesn't work.comment out for now)
# mount C /root/dosbox/c # <-- not working. getting permission denied. May have to use persistent docker volumes
# c:\
# myapp.bat

##########################
#EXAMPLE 2) run python app
##########################
#cd /root/app/python
#python myapp.py

###########################
#EXAMPLE 3) run node.js app
###########################
#cd /root/app/nodejs
#node myapp.js

###########################
#EXAMPLE 4) dotnet core app
###########################
#export DOTNET_CLI_HOME=/root
#cd /root/app/dotnetcore
#dotnet run

######################################
#EXAMPLE 5) launch powershell core app
######################################
clear
cd /root/app/powershellcore
pwsh -File ./myapp.ps1

#clear
echo "Program completed. Exiting in 5 seconds..."
sleep 5s
#very important to have an exit line, so the user isn't retured to a bash shell
exit