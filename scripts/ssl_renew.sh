RPOJECT_PATH=/usr/src/natours
DOMAIN=natours-club.site
DOCKER="/usr/bin/docker"

cd $PROJECT_PATH
$DOCKER compose run certbot renew && $DOCKER compose kill -s SIGHUP nginx
$DOCKER system prune -af
