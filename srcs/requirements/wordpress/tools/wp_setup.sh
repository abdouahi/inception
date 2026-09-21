#!/bin/bash
set -e

# Read secrets from files if provided
if [ -n "$DB_PASSWORD_FILE" ] && [ -f "$DB_PASSWORD_FILE" ]; then
    MYSQL_PASSWORD=$(cat "$DB_PASSWORD_FILE" | tr -d '\r\n')
fi

if [ -n "$WP_ADMIN_PASSWORD_FILE" ] && [ -f "$WP_ADMIN_PASSWORD_FILE" ]; then
    WP_ADMIN_PASSWORD=$(cat "$WP_ADMIN_PASSWORD_FILE" | tr -d '\r\n')
fi

if [ -n "$WP_USER_PASSWORD_FILE" ] && [ -f "$WP_USER_PASSWORD_FILE" ]; then
    WP_USER_PASSWORD=$(cat "$WP_USER_PASSWORD_FILE" | tr -d '\r\n')
fi

mkdir -p /var/www/wordpress /run/php
cd /var/www/wordpress

# Wait for MariaDB service to be accessible
echo "[WordPress] Waiting for MariaDB service (mariadb:3306)..."
while ! mariadb -h mariadb -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1;" >/dev/null 2>&1; do
    sleep 2
done
echo "[WordPress] MariaDB is up and accepting connections."

# Download WordPress core files if index.php does not exist
if [ ! -f "/var/www/wordpress/index.php" ]; then
    echo "[WordPress] Downloading WordPress core..."
    wp core download --allow-root
fi

# Generate wp-config.php if missing
if [ ! -f "/var/www/wordpress/wp-config.php" ]; then
    echo "[WordPress] Creating wp-config.php..."
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root
fi

# Install WordPress and configure admin / user if not installed
if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "[WordPress] Installing WordPress..."
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE:-Inception 42}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    echo "[WordPress] Creating regular user '${WP_USER}'..."
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root
fi

# Ensure correct permissions
chown -R www-data:www-data /var/www/wordpress

echo "[WordPress] Starting PHP-FPM 8.2 in foreground on port 9000..."
exec php-fpm8.2 -F

