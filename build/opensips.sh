#!/bin/sh
set -e
echo "Welcome to OpenSIPS"

CFG=/usr/local/etc/opensips/opensips.cfg

if [ ! -f "$CFG" ]; then
    echo "ERROR: $CFG not found. Mount your opensips.cfg to $CFG." >&2
    exit 1
fi

exec /usr/local/sbin/opensips -M 8 -m 256 -F -f "$CFG" "$@"
