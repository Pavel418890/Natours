#! /bin/sh

set -e 

export DOMAIN=localhost
export PROJECT_PATH=/home/plots/natours

DOCKER=/usr/bin/docker

find $PROJECT_PATH/backend/src -type f -name "*.pyc" -o -name "*.pyo" -exec rm -fr "{}" \;

$DOCKER compose -f $PROJECT_PATH/backend/docker-compose.yaml down
    
