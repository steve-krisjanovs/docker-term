# Synopsis

This debian-based docker image allows you to serve a volume-mounted console application over Telnet and SSH.

Simply create your app as you would create any other console app (e.g. node.js, .net core, bash, powershell, etc) and let this container serve that app to your end users via Telnet/SSH. 

Where most ANSI/VT-based data capture applications in the enterprise typically each implement their own Telnet socket layer, this solution leverages sshd and inetd services to do that for you. If you can write console applications (or already have one available), you can easily serve up those applications to your end users over your network.

Some sample use cases for building such text-based terminal applications include (but not limited to):

* Inventories / Cycle Counts
* Warehouse Management Systems (shipping/receiving/pick/pack/putaway/etc.)
* Item inquiries (e.g. scan a barcode to inquire price/UOM/description/quantity on-hand/etc.)
* EDI outbound scanning (e.g. ASC X12 856 + MH10 labels)

# Introduction

I developed this docker container where I saw a need for businesses who require a text-based VTxxx interface to easily customize and automate their operations (e.g. text-based VT100 data capture scanner guns, WindowsMobile/CE rugged handheld devices with a VT100 client, etc.). Many businesses have a substantial legacy investment in these perfectly-functional older devices, but there is a growing trend in the enterprise world where businesses are expected to replace their VT100 legacy scanner investment for newer iOS/Android-based technologies. 

It's my hope that this container serves a niche for those who cannot upgrade their legacy scanner hardware yet.

# Usage

```
docker pull docker pull stevekrisjanovs/docker-term
docker run --env ROOT_PASSWORD=pass1234 --volume=C:\my:/root/my --detach --rm -p 10023:23 -p 10022:22 --name docker-term stevekrisjanovs/docker-term
```

The above command does the following:
* sets the root password for the container (this is mandatory)
* expose telnet port 23 as host port 10023
* expose SSH port 22 as host port 10022
* mounts the host directory C:\my to the container's /root/my directory. This mounted host volume contains the following mandatory items in it's root directory:
  * your console app you want to serve up over SSH/Telnet (bash, dotnet core, nodejs, pwsh, wine, dosemu, etc.)
  * login.sh: this is the shell script that launches your application mounted in /root/my
  * init.sh: this initializes your application (e.g. compile, npm install)

Refer to the github page for this repository for a sample bash script that is served over SSH/Telnet

**NOTE** linux files (config files, .sh files, etc) expect to be *nix LF format. If you're running this container from a windows host, be sure that your login.sh and init.sh in the mounted volume are LF format. NOT CRLF!

If you want to omit what ptty services are exposed, simply omit one of them from your docker run command e.g.

* `-p 10023:23` exposes telnet on port 10023
* `-p 10022:22` exposes ssh on port 10022

Omitting both will obviously render the container useless!

Some pros/cons of Telnet vs. SSH:

* telnet
  * PRO: excellent legacy device support (virtually everything supports telnet)
  * PRO: easily bypasses linux username/password prompt (users are directed to the app once a telnet connection is established)
  * CON: no encryption (do NOT serve this container in the public internet if using Telnet! on-premise/private cloud only)
* SSH
  * PRO: encrypted traffic to prevent sniffing
  * CON: requires an SSH client (e.g. JuiceSSH for Android, Termius for iOS, etc) which isn't common on older devices
  * CON: rebuilding the container will generate a new SSH server key
  * CON: user must supply root+password when connecting. persistent ssh keys via volume mounts are currently not yet supported in this release (PR's are welcome!). 

When the container launches, the container internally runs a keepalive.sh script as the last step. This script sets the root password, initializes SSH and Telnet (if you review the dockerfile, a custom telnet config file is initialized so inetd skips unix logon prompt and launches your login.sh istead), and lastly launches the init.sh located in the root of the mounted volume on the host. The init.sh is where you want to set you compile your app, run npm install on your app, etc.

Users connecting via telnet will be automatically logged in as root redirected to /root/my/login.sh and the telnet session will terminate when login.sh ends

Users connecting via SSH will need to first provide the root+password to login. Once logged in, the container's ~/.bashrc file ensures that SSH users are directed to the login.sh. The SSH session will end when login.sh terminates.

As such, the login.sh that resides on your mounted volume root is what you customize to launch your app.

# Connection and shell script execution workflow

Depending on how a user connects into your app, the workflow is as follows:

* For SSH: ssh connect >> ssh login >> .bashrc >> /root/my/login.sh >> exit
* For Telnet: telnet connect (login bypass) >> /root/my/login.sh >> exit

# Screenshots

Sample screenshot of a sample /root/my/login.sh in action when establishing a connection to telnet port 10023:

![Screenshot](screenshot.png)

