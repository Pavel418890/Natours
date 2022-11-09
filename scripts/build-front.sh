#! /bin/sh

set -e

export DOMAIN=natours-club.site
export PROJECT_PATH=/usr/src/natours

DOCKER=/usr/bin/docker

rm -fr frontend/dist

$DOCKER build -t frontend:build --build-arg DOMAIN=$DOMAIN frontend
$DOCKER create --init --name=frontend-build frontend:build 
$DOCKER cp frontend-build:/dist frontend/
$DOCKER  rm -f frontend-build
