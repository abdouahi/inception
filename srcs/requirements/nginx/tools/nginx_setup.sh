#!/bin/bash
set -e

# Create SSL directory if missing
mkdir -p /etc/nginx/ssl

# Generate self-signed SSL certificate if it does not already exist
if [ ! -f /etc/nginx/ssl/inception.crt ] || [ ! -f /etc/nginx/ssl/inception.key ]; then
    echo "[NGINX] Generating self-signed SSL certificate for ${DOMAIN_NAME:-abdouahi.42.fr}..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=MA/ST=Tetouan/L=Tetouan/O=1337/OU=student/CN=${DOMAIN_NAME:-abdouahi.42.fr}"
fi

echo "[NGINX] Starting NGINX in foreground on port 443..."
exec nginx -g 'daemon off;'
