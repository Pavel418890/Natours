SHELL := /bin/bash

natours-frontend: 
	docker build \
		-t plots418890/natours-frontend:${FRONTEND_TAG} \
	       	--build-arg API_URL=${API_URL} \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--build-arg VCS_REF=`git submodule status ./frontend | awk '{print $$1;}'` \
	      	./frontend 
	docker push plots418890/natours-frontend:${FRONTEND_TAG}
	docker create --init --name=frontend-build "plots418890/natours-frontend:${FRONTEND_TAG}"
	docker cp frontend-build:/dist ./frontend
	docker rm -f frontend-build

natours-backend:
	docker build \
		-f backend/Dockerfile \
		-t plots418890/natours-backend:${BACKEND_TAG} \
		--build-arg DOMAIN=${DOMAIN} \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--build-arg VCS_REF=`git submodule status ./backend | awk '{print $$1;}'` \
		./backend
	docker push "plots418890/natours-backend:${BACKEND_TAG}"

certs:
	mkdir -p ./certs
	openssl dhparam -out ./certs/dhparam-2048.pem 2048

backend-logs:
	docker service logs -f natours_backend

# nginx server log
access-logs:
	tail -f api.natours-club.site.access.log	

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
