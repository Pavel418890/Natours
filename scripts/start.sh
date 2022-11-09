#! /bin/sh

set -e 

export DOCKER=/usr/bin/docker
export DOMAIN=localhost
export PROJECT_PATH=/home/plots/natours
export API_SCHEMA=http
export API_PORT=8000
export API_URL=$API_SCHEMA://$DOMAIN:$API_PORT

$PROJECT_PATH/scripts/build-front.sh


$DOCKER compose \
  -f $PROJECT_PATH/backend/docker-compose.yaml build \
  --build-arg DOMAIN=$DOMAIN \
  --build-arg PROJECT_PATH=$PROJECT_PATH

$DOCKER  compose -f $PROJECT_PATH/backend/docker-compose.yaml up -d 
