#!/bin/sh
# Configure module
set -e

SCRIPT_DIR=$(dirname $0)
ROOT_DIR=../../roots

#chown -R jboss:root $SCRIPT_DIR
#chmod -R ug+rwX $SCRIPT_DIR
#chmod ug+x ${ROOT_DIR}/*

pushd ${ROOT_DIR}
cp -pr * /
popd