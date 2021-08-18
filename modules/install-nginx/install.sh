microdnf install -y nginx-${NGINX_MAJOR_VERSION}.${NGINX_MINOR_VERSION}.${NGINX_BUILD_VERSION} && \
microdnf update -y && \
microdnf clean all