#! /bin/bash

set -e 

DOCKER="/usr/bin/docker"

$DOCKER run \
        --rm \
        --mount 'type=volume,source=natours_webroot,target=/var/www/html/,volume-driver=local,volume-opt=type=none,volume-opt=device=/usr/src/natours/frontend/dist/,volume-opt=o=bind' \
        -v natours_certbot_etc:/etc/letsencrypt \
        -v natours_certbot_var:/var/lib/letsencrypt \
        certbot/certbot renew && \
        $DOCKER service update --force natours-club-site_nginx

$DOCKER system prune -af
