#!/bin/bash
set -e

# Read secrets from files if provided
if [ -n "$DB_PASSWORD_FILE" ] && [ -f "$DB_PASSWORD_FILE" ]; then
    MYSQL_PASSWORD=$(cat "$DB_PASSWORD_FILE" | tr -d '\r\n')
fi

if [ -n "$DB_ROOT_PASSWORD_FILE" ] && [ -f "$DB_ROOT_PASSWORD_FILE" ]; then
    MYSQL_ROOT_PASSWORD=$(cat "$DB_ROOT_PASSWORD_FILE" | tr -d '\r\n')
fi

# Ensure necessary runtime directories exist with correct ownership
mkdir -p /run/mysqld /var/lib/mysql /var/log/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql /var/log/mysql

# Initialize system tables if not present
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[MariaDB] Initializing database system tables in /var/lib/mysql..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

# Check if application database exists, if not configure users & permissions
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "[MariaDB] Setting up database and user accounts..."
    
    # Start mysqld temporarily in background
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    pid="$!"

    # Wait until MariaDB responds
    for i in {30..0}; do
        if mariadb-admin ping --silent 2>/dev/null; then
            break
        fi
        sleep 1
    done

    if [ "$i" -eq 0 ]; then
        echo "[MariaDB] Error: Database initialization timeout" >&2
        exit 1
    fi

    # Create Database, User, and set root password
    mariadb -u root <<EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    echo "[MariaDB] Database '${MYSQL_DATABASE}' and user '${MYSQL_USER}' created successfully."

    # Stop temporary background mysqld
    mariadb-admin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait "$pid"
fi

echo "[MariaDB] Starting MariaDB server in foreground on port 3306..."
exec mysqld_safe --datadir=/var/lib/mysql
