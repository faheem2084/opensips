#!/bin/sh
echo "Welcome to OpenSIPS";
envsubst < /templates/opensips.cfg.tpl > /usr/local/etc/opensips/opensips.cfg;
/usr/local/sbin/opensips -M 8 -m 256 -FE -f /usr/local/etc/opensips/opensips.cfg "$@"
exec "$@"
