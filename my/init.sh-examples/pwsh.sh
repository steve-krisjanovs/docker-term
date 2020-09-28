#!/bin/sh

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