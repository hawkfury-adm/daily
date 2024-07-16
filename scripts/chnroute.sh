#!/bin/bash -e
set -o pipefail

CUR_DIR=$(pwd)
TMP_DIR=$(mktemp -d /tmp/chnroute.XXXXXX)

SRC_URL_1="https://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest"
SRC_URL_2="https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt"
DEST_FILE_1="dist/chnroute.txt"
DEST_FILE_2="dist/chnroute6.txt"

cd $TMP_DIR

curl -4fsSL $SRC_URL_1 -o apnic.txt
curl -4fsSL $SRC_URL_2 -o ipip-v4.txt


# convert to cidr format
cat apnic.txt | grep ipv4 | grep CN | awk -F\| '{ printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > apnic-v4.tmp
# add newline to end of file only if newline doesn't exist
sed '$a\' ipip-v4.txt > ipip-v4.tmp

# ipv4 cidr merge
cat apnic-v4.tmp ipip-v4.tmp | $CUR_DIR/tools/ip-dedup -4 > chnroute.txt

# convert to cidr format
cat apnic.txt | grep ipv6 | grep CN | awk -F\| '{ printf("%s/%d\n", $4, $5) }' > apnic-v6.tmp

# ipv6 cidr merge
cat apnic-v6.tmp | $CUR_DIR/tools/ip-dedup -6 > chnroute6.txt

cd $CUR_DIR
install -D -m 644 $TMP_DIR/chnroute.txt $DEST_FILE_1
install -D -m 644 $TMP_DIR/chnroute6.txt $DEST_FILE_2

rm -rf $TMP_DIR
echo "[$(basename $0 .sh)]: done."
