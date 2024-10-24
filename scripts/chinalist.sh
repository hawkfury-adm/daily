#!/bin/bash -e
set -o pipefail

CUR_DIR=$(pwd)
TMP_DIR=$(mktemp -d /tmp/chinalist.XXXXXX)

SRC_URL_1="https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/apple.china.conf"
SRC_URL_2="https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/google.china.conf"
SRC_URL_3="https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf"
DEST_FILE="dist/chinalist.txt"

cd $TMP_DIR

curl -4fsSL $SRC_URL_1 -o apple.conf
curl -4fsSL $SRC_URL_2 -o google.conf
curl -4fsSL $SRC_URL_3 -o china.conf

cat apple.conf google.conf china.conf |
  # remove empty lines
  sed '/^[[:space:]]*$/d' |
  # remove comment lines
  sed '/^#/ d' |
  # extract domains
  awk '{split($0, arr, "/"); print arr[2]}' |
  # remove TLDs
  grep "\." |
  # remove duplicates
  awk '!x[$0]++' > chinalist.txt

sed "s|^|nameserver /|" chinalist.txt | sed "s|$|/china|" > smartdns.conf

cd $CUR_DIR
install -D -m 644 $TMP_DIR/chinalist.txt $DEST_FILE
install -D -m 644 $TMP_DIR/smartdns.conf dist/smartdns.conf

rm -rf $TMP_DIR
echo "[$(basename $0 .sh)]: done."
