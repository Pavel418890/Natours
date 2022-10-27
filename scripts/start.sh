#! /bin/sh

set -e 

DOMAIN=natours-club.site
PROJECT_PATH=/usr/src/natours
DOCKER=/usr/bin/docker

$DOCKER compose build 
$DOCKER  compose -f docker-compose.yaml up -d 

