rem assumes that dockerfile is built with the name "docker-term"
docker stop docker-term
docker run -it --rm -p 10023:23 -p 10022:22 --name docker-term docker-term sh