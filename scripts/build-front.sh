#! /bin/sh

set -e

DOCKER=/usr/bin/docker

rm -fr $PROJECT_PATH/frontend/dist

$DOCKER build -t frontend:build --build-arg  API_URL=$API_URL $PROJECT_PATH/frontend
$DOCKER create --init --name=frontend-build frontend:build 
$DOCKER cp frontend-build:/dist $PROJECT_PATH/frontend/
$DOCKER  rm -f frontend-build
