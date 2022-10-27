#! /bin/sh

set -e 

DOMAIN=natours-club.site
PROJECT_PATH=/usr/src/natours
DOCKER=/usr/bin/docker

find $PROJECT_PATH -type f -name "*.pyc" -o -name "*.pyo" -exec rm -fr "{}" \;

$DOCKER compose down
$DOCKER compose	-f docker-compose.yaml up -d --force-recreate pg rabbit redis nginx backend celeryworker 

