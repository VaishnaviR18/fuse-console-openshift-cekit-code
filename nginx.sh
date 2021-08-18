#!/bin/sh

# Fail on a single failed command in a pipeline (if supported)
(set -o | grep -q pipefail) && set -o pipefail

# Fail on error and undefined vars
set -eu

./config.sh > config.js

echo Starting NGINX...
if [ -v HAWTIO_ONLINE_RBAC_ACL ]; then
  echo Using RBAC NGINX configuration
  nginx -g 'daemon off;load_module modules/ngx_http_js_module.so;' -c /etc/nginx/nginx-gateway.conf
elif [ "${HAWTIO_ONLINE_GATEWAY:-}" = "true" ]; then
  echo Using gateway NGINX configuration
  nginx -g 'daemon off;load_module modules/ngx_http_js_module.so;' -c /etc/nginx/nginx-gateway.conf
else
  echo Using legacy NGINX configuration
  nginx -g 'daemon off;' -c /etc/nginx/nginx-legacy.conf
fi

if [ $? != 0 ]; then
  exit 1
fi