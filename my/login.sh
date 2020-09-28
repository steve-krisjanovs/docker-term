#!/bin/bash

export HOME=/root/

#This is a demo telnet/SSH shell app. Prompts for user's name, presents welcome message, then exits.
set echo off
clear
echo "TERM=$TERM"
echo "Enter your name"
set echo on
read name
echo "Welcome $name"
echo "Program completed. Exiting in 5 seconds..."
sleep 5s

#very important to have an exit line, so the user isn't retured to a bash shell
exit