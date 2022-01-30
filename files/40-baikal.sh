#!/bin/sh

# Based on /etc/docker-entrypoint.d/10-listen-on-ipv6-by-default.sh, since the
# same one cannot be used because the checksum of the default.conf differs.

set -e
ME=$(basename $0)

# Start PHP
if [ -f "/etc/init.d/php8.0-fpm" ]; then
  echo >&3 "$ME: info: Starting PHP 8.0"
  /etc/init.d/php8.0-fpm start
elif [ -f "/etc/init.d/php8.1-fpm" ]; then
  echo >&3 "$ME: info: Starting PHP 8.1"
  /etc/init.d/php8.1-fpm start
fi

# Fix file permissions for mounted files
echo >&3 "$ME: info: Fixing Baikal file permissions"
chown -R nginx:nginx /var/www/baikal/Specific

# Disable IPv6 configuration if not supported
# Added to resolve https://github.com/ckulka/baikal-docker/issues/73
if nginx -t 2>&1 >/dev/null | grep -q '\[emerg\] socket() \[::\]:80 failed (97: Address family not supported by protocol)'; then
    echo >&3 "$ME: info: Disable IPv6 in configuration"
    sed -i 's/listen \[::\]:80;/# listen \[::\]:80/' /etc/nginx/conf.d/default.conf
fi
