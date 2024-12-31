#!/bin/sh -eu

flutter build web --release --dart-define PF_API_ENDPOINT=${PF_API_ENDPOINT}

chmod -R 755 /usr/share/nginx/html
cp -r /app/build/web/* /usr/share/nginx/html

nginx -g "daemon off;"