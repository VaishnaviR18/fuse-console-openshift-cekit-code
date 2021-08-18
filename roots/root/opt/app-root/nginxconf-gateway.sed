/listen/s%80%8000%
s/^user *nginx;//
s%/run/nginx.pid%/var/cache/nginx/nginx.pid%
s%/etc/nginx/conf.d/\*\.conf%/opt/app-root/etc/nginx.d/nginx-gateway.conf%
s%/etc/nginx/default.d/%/opt/app-root/etc/nginx.default.d/%
s%/usr/share/nginx/html%/opt/app-root/src%
s%/var/log/nginx/error.log%stderr%
s%access_log  /var/log/nginx/access.log  main;%%