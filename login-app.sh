#!/bin/sh
clear

#run yout TUI app here
cd /root
python myapp.py
clear

#once the above app finishes, present user with a disconnect countdown
for i in 3 2 1 0
do
  sleep 1s
  clear
  echo "Exiting in $i secs...."
done
clear

#very important to have an exit line, so the user isn't retured to a bash shell
exit