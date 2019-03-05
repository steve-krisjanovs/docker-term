#!/bin/sh
#assumes that dockerfile is built with the name "docker-term"
sudo docker stop docker-term
sudo docker run --detach --rm -p 10023:23 -p 10022:22 --name docker-term docker-term