SHELL := /bin/bash
FRONTEND_TAG = `git -C ./frontend describe --tags`
BACKEND_TAG = `git -C ./backend describe --tags`
DOMAIN = natours-club.site
API_URL = https://api.${DOMAIN}

natours-frontend:
	docker build \
		-t plots418890/natours-frontend:latest \
		-t plots418890/natours-frontend:${FRONTEND_TAG} \
	       	--build-arg API_URL=${API_URL} \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--build-arg VCS_REF=`git -C frontend rev-parse HEAD` \
	      	frontend 
	docker push plots418890/natours-frontend:${FRONTEND_TAG}
	docker push plots418890/natours-frontend:latest
	docker create --init --name=frontend-build "plots418890/natours-frontend:${FRONTEND_TAG}"
	docker cp frontend-build:/dist ./frontend
	docker rm -f frontend-build

natours-backend:
	docker build \
		-t plots418890/natours-backend:latest \
		-t plots418890/natours-backend:${BACKEND_TAG} \
		--build-arg DOMAIN=${DOMAIN} \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--build-arg VCS_REF=`git -C backend rev-parse HEAD` \
		backend
	docker push plots418890/natours-backend:latest
	docker push "plots418890/natours-backend:${BACKEND_TAG}"

certs:
	mkdir -p ./certs
	openssl dhparam -out ./certs/dhparam-2048.pem 2048

backend-logs:
	docker service logs -f natours_backend

# nginx server log
access-logs:
	tail -f /var/log/natours-club.site/log/api.natours-club.site.access.log	

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

loadtest:
	hey \
	-m get \
	-c 100 \
	-n 1000000 \
	"https://api.natours-club.site/v2/tours/"
		
