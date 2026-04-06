#!/bin/sh
set -eu

export NGINX_LISTEN_PORT="${NGINX_LISTEN_PORT:-${PORT:-8080}}"
NGINX_RESOLVER="${NGINX_RESOLVER:-$(awk '/^nameserver / { print $2; exit }' /etc/resolv.conf)}"

if [ -z "${GATEWAY_UPSTREAM:-}" ]; then
    echo "GATEWAY_UPSTREAM must be set for the Railway nginx service" >&2
    exit 1
fi

if [ -z "${NGINX_RESOLVER}" ]; then
    echo "Could not determine an nginx resolver address" >&2
    exit 1
fi

case "${NGINX_RESOLVER}" in
    *:*)
        export NGINX_RESOLVER="[${NGINX_RESOLVER}]"
        ;;
    *)
        export NGINX_RESOLVER
        ;;
esac

envsubst '${GATEWAY_UPSTREAM} ${NGINX_LISTEN_PORT} ${NGINX_RESOLVER}' \
    < /etc/nginx/nginx.conf.template \
    > /etc/nginx/nginx.conf

exec nginx -g 'daemon off;'
