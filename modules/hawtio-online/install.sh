pushd /opt/app-root/src/ && \
microdnf install tar && \
tar --no-same-owner -xvf hawtio-online-$HAWTIO_ONLINE_VERSION-dist.tar.gz && \
microdnf remove tar && \
microdnf clean all && \
rm hawtio-online-$HAWTIO_ONLINE_VERSION-dist.tar.gz && \
popd