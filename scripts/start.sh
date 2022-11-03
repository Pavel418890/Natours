#! /bin/sh

set -e 

export DOMAIN=natours-club.site
export PROJECT_PATH=/usr/src/natours
DOCKER=/usr/bin/docker

$DOCKER compose build 
$DOCKER  compose -f docker-compose.yaml up -d 

