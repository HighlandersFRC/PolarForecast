#!/bin/sh -eu

flutter build web --release --dart-define PF_API_ENDPOINT=${PF_API_ENDPOINT} --dart-define KEYCLOAK_REALM=${KEYCLOAK_REALM} --dart-define KEYCLOAK_APP_CLIENT_ID=${KEYCLOAK_APP_CLIENT_ID} --dart-define PF_KEYCLOAK_LOGIN_IP=${PF_KEYCLOAK_LOGIN_IP} --dart-define APP_DOMAIN=${APP_DOMAIN}

chmod -R 755 /usr/share/nginx/html
cp -r /app/build/web/* /usr/share/nginx/html

nginx -g "daemon off;"