#!/bin/bash

sudo mkdir -p /dat/idr_viewer
echo '=============== Created /dat/idr_viewer directory ==============='

echo '=============== Starting building docker image ==============='
docker build -t idr_viewer .
echo '=============== Finished building docker image ==============='

docker run -d -v /dat/idr_viewer:/idr_viewer/dat --network smartinetwork --restart=always -p 8060:8060 --name idr_viewer idr_viewer:240311