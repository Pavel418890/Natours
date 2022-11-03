#! /bin/sh

set -e 

export DOMAIN=natours-club.site
export PROJECT_PATH=/usr/src/natours
DOCKER=/usr/bin/docker

find $PROJECT_PATH -type f -name "*.pyc" -o -name "*.pyo" -exec rm -fr "{}" \;

$DOCKER compose down
$DOCKER compose build --build-arg DOMAIN_ARG=$DOMAIN --build-arg PROJECT_PATH_ARG=$PROJECT_PATH
$DOCKER compose	-f docker-compose.yaml up -d --force-recreate pg rabbit redis nginx backend celeryworker 

