#!/bin/sh
# Configure module
set -e

SCRIPT_DIR=$(dirname $0)
RHEL_SOURCE_DIR=../../rhel

#chown -R jboss:root $SCRIPT_DIR
#chmod -R ug+rwX $SCRIPT_DIR
#chmod ug+x ${RHEL_SOURCE_DIR}/*

pushd ${RHEL_SOURCE_DIR}
cp -pr * /
popd