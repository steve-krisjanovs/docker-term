Write-Host "Removing old images" -ForegroundColor Yellow
docker stop docker-term
docker image rm docker-term --force
docker container rm docker-term --force
Write-Host "Building docker image" -ForegroundColor Yellow
docker build --tag docker-term .
Write-Host "Run docker container..." -ForegroundColor Yellow
docker run --env ROOT_PASSWORD=pass1234 --volume=$PSScriptRoot\my:/root/my --detach --rm -p 10023:23 -p 10022:22 --name docker-term docker-term
Write-Host "FINISHED" -ForegroundColor Yellow