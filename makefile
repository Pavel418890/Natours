SHELL := /bin/bash

natours-frontend: 
	docker build -t frontend:build --build-arg API_URL=${API_URL} ./frontend
	docker create --init --name=frontend-build frontend:build
	docker cp frontend-build:/dist ./frontend
	docker rm -f frontend-build

natours-backend:
	docker compose -f ./backend/docker-compose.yaml build \
	--build-arg DOMAIN=${DOMAIN} 
	docker compose -f ./backend/docker-compose.yaml up -d

certs:
	mkdir -p ./certs
	openssl dhparam -out ./certs/dhparam-2048.pem 2048

backend-logs:
	docker service logs -f natours_backend

access-logs:
	docker service logs -f natours_nginx

# Daily Cron job for renew ssl certs
# crontab -e 
# 0 12 * * * make --trace --makefile /usr/src/natours/makefile ssl-renew >> /var/log/cron.log 2>&1
# Before launch testing purpose better use the --dry-run flag 
ssl-renew:
	 docker run \
		--rm \
		--mount 'type=volume,source=natours_webroot,target=/var/www/html/,volume-driver=local,volume-opt=type=none,volume-opt=device=/usr/src/natours/frontend/dist/,volume-opt=o=bind' \
		-v natours_certbot_etc:/etc/letsencrypt \
		-v natours_certbot_var:/var/lib/letsencrypt \
		certbot/certbot renew   
	docker service update --force natours_nginx
	docker system prune -af 
