yumdownloader --source nginx-${NGINX_MAJOR_VERSION}.${NGINX_MINOR_VERSION}.${NGINX_BUILD_VERSION}
rpm -ivh nginx-${NGINX_MAJOR_VERSION}.${NGINX_MINOR_VERSION}.${NGINX_BUILD_VERSION}-*.src.rpm
mkdir -p /root/rpmbuild/SOURCES/nginx-src

cd /root/rpmbuild/SOURCES && tar -xvf nginx-${NGINX_MAJOR_VERSION}.${NGINX_MINOR_VERSION}.${NGINX_BUILD_VERSION}.tar.gz --strip-components=1 -C ./nginx-src

# CFLAGS=-Wno-error=cast-function-type needed for the nginx compilation issue with gcc >= 8.1.0
# See: https://trac.nginx.org/nginx/ticket/1546
cd /root/rpmbuild/SOURCES/nginx-src && CFLAGS=-Wno-error=cast-function-type ./configure \
--add-dynamic-module=${REMOTE_SOURCE_DIR}/app/nginx \
--prefix=/usr/share/nginx \
--sbin-path=/usr/sbin/nginx \
--modules-path=/usr/lib64/nginx/modules \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--http-client-body-temp-path=/var/lib/nginx/tmp/client_body \
--http-proxy-temp-path=/var/lib/nginx/tmp/proxy \
--http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi \
--http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi \
--http-scgi-temp-path=/var/lib/nginx/tmp/scgi \
--pid-path=/run/nginx.pid \
--lock-path=/run/lock/subsys/nginx \
--user=nginx --group=nginx --with-file-aio --with-http_ssl_module \
--with-http_v2_module --with-http_auth_request_module --with-http_realip_module \
--with-http_addition_module --with-http_xslt_module=dynamic \
--with-http_image_filter_module=dynamic --with-http_sub_module \
--with-http_dav_module --with-http_flv_module --with-http_mp4_module \
--with-http_gunzip_module --with-http_gzip_static_module \
--with-http_random_index_module --with-http_secure_link_module \
--with-http_degradation_module --with-http_slice_module \
--with-http_stub_status_module --with-http_perl_module=dynamic \
--with-mail=dynamic --with-mail_ssl_module --with-pcre --with-pcre-jit \
--with-stream=dynamic --with-stream_ssl_module --with-debug \
--with-cc-opt='-O2 -g -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -Wp,-D_GLIBCXX_ASSERTIONS -fexceptions -fstack-protector-strong -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -specs=/usr/lib/rpm/redhat/redhat-annobin-cc1 -m64 -mtune=generic -fasynchronous-unwind-tables -fstack-clash-protection -fcf-protection' \
--with-ld-opt='-Wl,-z,relro -Wl,-z,now -specs=/usr/lib/rpm/redhat/redhat-hardened-ld -Wl,-E' && \
 make modules