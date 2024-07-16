#!/bin/bash -e

CUR_DIR=$(pwd)
TMP_DIR=$(mktemp -d /tmp/cacert.XXXXXX)

DEST_FILE="dist/cacert.pem"

cd $TMP_DIR

curl -4fsSL https://curl.se/ca/cacert.pem -o cacert.pem

cd $CUR_DIR
install -D -m 644 $TMP_DIR/cacert.pem $DEST_FILE

rm -rf $TMP_DIR
echo "[$(basename $0 .sh)]: done."
