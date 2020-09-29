Write-Host "Removing old images" -ForegroundColor Yellow
docker stop docker-term
docker image rm docker-term --force
docker container rm docker-term --force
Write-Host "Building docker image" -ForegroundColor Yellow
docker build --tag docker-term .
Write-Host "Finished" -ForegroundColor Yellow