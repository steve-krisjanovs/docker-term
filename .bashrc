SESSION_TYPE=""
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  SESSION_TYPE="remote/ssh"
# many other tests omitted
else
  case $(ps -o comm= -p $PPID) in
    sshd|*/sshd) SESSION_TYPE="remote/ssh";;
  esac
fi
if ["$SESSION_TYPE" -ne "remote/ssh"]; then
    exit
else
    ./login-app.sh
    exit
fi

