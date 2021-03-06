#!/bin/bash
# From https://github.com/tburry/travis-nginx-test

# Exit if anything fails AND echo each command before executing
# http://www.peterbe.com/plog/set-ex
set -ex

USER=$(whoami)

ROOT=$WP_DIR
PORT=9000
SERVER=wordpress.dev

function tpl {
  sed \
    -e "s|{DIR}|$NGINX_DIR|g" \
    -e "s|{USER}|$USER|g" \
    -e "s|{PHP_VERSION}|$PHP_VERSION|g" \
    -e "s|{ROOT}|$ROOT|g" \
    -e "s|{PORT}|$PORT|g" \
    -e "s|{SERVER}|$SERVER|g" \
    < $1 > $2
}

mkdir -p "$NGINX_DIR/nginx/sites-enabled"

# Configure the PHP handler.

PHP_FPM_CONF="$NGINX_DIR/nginx/php-fpm.conf"

# Start php-fpm.
tpl "$BIN_DIR/conf/php-fpm.tpl.conf" "$PHP_FPM_CONF"
"$PHP_FPM_BIN" --allow-to-run-as-root --fpm-config "$PHP_FPM_CONF"

# Build the default nginx config files.
tpl "$BIN_DIR/conf/nginx.tpl.conf" "$NGINX_DIR/nginx/nginx.conf"
tpl "$BIN_DIR/conf/fastcgi.tpl.conf" "$NGINX_DIR/nginx/fastcgi.conf"
tpl "$BIN_DIR/conf/default-site.tpl.conf" "$NGINX_DIR/nginx/sites-enabled/default-site.conf"

# Start nginx.
nginx -c "$NGINX_DIR/nginx/nginx.conf"
