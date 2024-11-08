#!/bin/sh

envsubst '${WEB_HOST}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Start NGINX in the foreground
nginx -g 'daemon off;'