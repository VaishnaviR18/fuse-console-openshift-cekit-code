mkdir -p /opt/app-root/etc/nginx
cp /etc/nginx/nginx.conf /tmp/nginx-orig.conf && \
sed -i '/listen/s%80%8000%' /etc/nginx/nginx.conf && \
sed -i 's%/run/nginx.pid%/var/cache/nginx/nginx.pid%' /etc/nginx/nginx.conf && \
sed -f /opt/app-root/nginxconf.sed /tmp/nginx-orig.conf > /etc/nginx/nginx-legacy.conf && \
sed -f /opt/app-root/nginxconf-gateway.sed /tmp/nginx-orig.conf > /etc/nginx/nginx-gateway.conf && \
mkdir -p /opt/app-root/etc/nginx.d/ && \
mkdir -p /opt/app-root/etc/nginx.default.d/ && \
chown -R 999:0 /etc/nginx && \
chmod -R g+w /etc/nginx && \
chown -R 1001:0 /opt/app-root && \
chmod -R a+rwx /opt/app-root/etc 