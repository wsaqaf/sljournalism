#!/bin/bash
docker system prune --volumes -f
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker rmi $(docker images -a -q)
docker volume rm $(docker volume ls -q)
docker image prune -a -f
docker volume prune -f
docker network prune -f
rm -rf fabric-samples
curl -sSL https://bit.ly/2ysbOFE | bash -s
