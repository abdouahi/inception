# User Documentation (USER_DOC.md)

This guide is intended for end users and administrators who want to operate, access, and verify the Inception web infrastructure.

---

## 1. Services Provided by the Stack

The Inception infrastructure provides a complete, secure WordPress CMS platform composed of three orchestrated services:
1. **NGINX (Gateway / Reverse Proxy)**:
   - Accepts all incoming HTTPS traffic on port **443** using **TLSv1.2** or **TLSv1.3**.
   - Handles SSL termination and serves static content.
   - Forwards PHP requests to WordPress.
2. **WordPress (CMS Application)**:
   - Powered by **PHP-FPM 7.4** running on FastCGI port **9000**.
   - Contains all WordPress core files, plugins, themes, and uploaded media.
3. **MariaDB (Database Engine)**:
   - Relational database storing WordPress posts, users, comments, and settings.
   - Communicates securely over internal port **3306**.

---

## 2. Starting and Stopping the Project

All operational commands are managed via the root `Makefile`:

| Action | Command | Description |
| :--- | :--- | :--- |
| **Start Infrastructure** | `make` or `make all` | Builds images, creates directories, and launches all containers in detached mode. |
| **Stop Infrastructure** | `make stop` | Pauses running containers without destroying them. |
| **Resume Infrastructure** | `make start` | Resumes previously stopped containers. |
| **Tear Down** | `make down` | Stops and removes active containers and network. |
| **Clean Reset** | `make clean` | Removes containers and networks. |
| **Purge Everything** | `make fclean` | Purges all containers, images, volumes, and persistent data on disk. |

---

## 3. Accessing the Website & Admin Panel

### Domain Configuration
Ensure your `/etc/hosts` file contains:
```
127.0.0.1 abdouahi.42.fr
```

### URLs
- **Public Website**: [https://abdouahi.42.fr](https://abdouahi.42.fr)
- **WordPress Administration Panel**: [https://abdouahi.42.fr/wp-login.php](https://abdouahi.42.fr/wp-login.php)

> **Note on Browser SSL Warning**: The site uses a self-signed TLS certificate generated during build time. Your browser will display a warning on the first visit; click **Advanced** -> **Proceed to abdouahi.42.fr (unsafe)**.

---

## 4. Locating and Managing Credentials

User credentials and secret keys are stored locally in the `secrets/` directory (which is ignored by Git for security):

- `secrets/credentials.txt`: Summary of all service credentials.
- `secrets/db_password.txt`: Password for MySQL user (`inception_user`).
- `secrets/db_root_password.txt`: MySQL root administrator password.
- `secrets/wp_admin_password.txt`: WordPress Administrator password.
- `secrets/wp_user_password.txt`: WordPress Author user password.

### Configured Accounts:
- **WordPress Administrator**:
  - Username: `chief_abdouahi` (Compliant with 42 subject: does not contain 'admin' or 'administrator')
  - Email: `chief_abdouahi@student.42.fr`
  - Role: Administrator
- **WordPress Author User**:
  - Username: `author_abdouahi`
  - Email: `author_abdouahi@student.42.fr`
  - Role: Author

---

## 5. Checking Service Health & Diagnostics

1. **Verify Running Containers**:
   ```bash
   make status
   ```
   *Expected output: Three containers (`nginx`, `wordpress`, `mariadb`) with status `Up`.*

2. **Inspect Container Logs**:
   ```bash
   make logs
   ```
   Or for individual services:
   ```bash
   docker logs nginx
   docker logs wordpress
   docker logs mariadb
   ```

3. **Verify TLS Protocols**:
   ```bash
   openssl s_client -connect abdouahi.42.fr:443 -tls1_2 < /dev/null
   openssl s_client -connect abdouahi.42.fr:443 -tls1_3 < /dev/null
   ```
