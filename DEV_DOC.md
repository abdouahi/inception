# Developer Documentation (DEV_DOC.md)

This documentation provides technical specifications, development guidelines, and environment setup instructions for developers maintaining or extending the Inception codebase.

---

## 1. Setting Up the Environment from Scratch

### Requirements
- **Host OS**: Debian 11/12, Ubuntu 20.04/22.04 LTS, or WSL2.
- **Software**:
  - `make`
  - `docker` (v20.10+)
  - `docker-compose` (v1.29+ or Docker Compose v2)
  - `openssl`, `curl`

### Repository Setup
1. Clone the repository:
   ```bash
   git clone <repository-url> inception
   cd inception
   ```

2. Review or customize environment variables in `srcs/.env`:
   ```env
   DOMAIN_NAME=abdouahi.42.fr
   DATA_PATH=/home/abdouahi/data
   MYSQL_DATABASE=inception_db
   MYSQL_USER=inception_user
   WP_TITLE=Inception 42 - abdouahi
   WP_ADMIN_USER=chief_abdouahi
   WP_ADMIN_EMAIL=chief_abdouahi@student.42.fr
   WP_USER=author_abdouahi
   WP_USER_EMAIL=author_abdouahi@student.42.fr
   ```


---

## 2. Building & Launching with Makefile & Docker Compose

### Makefile Targets
- `make all` / `make`: Automatically creates persistent storage directories (`/home/abdouahi/data/wordpress`, `/home/abdouahi/data/mariadb`), builds custom Docker images without cache issues, and starts all containers in detached mode.
- `make build`: Builds all Dockerfiles defined in `srcs/docker-compose.yml`.
- `make up`: Starts containers defined in Compose.
- `make down`: Gracefully stops and removes containers and networks.
- `make status`: Shows container status and exposed ports.
- `make logs`: Follows aggregate container log streams.
- `make clean`: Removes containers and orphaned networks.
- `make fclean`: Completely tears down containers, images, volumes, and local data directories.
- `make re`: Runs `fclean` followed by `all`.

---

## 3. Container Management & Useful CLI Commands

### Direct Container Execution
- **Run WP-CLI inside WordPress container**:
  ```bash
  docker exec -it wordpress wp user list --path=/var/www/wordpress --allow-root
  docker exec -it wordpress wp post list --path=/var/www/wordpress --allow-root
  ```

- **Inspect NGINX Configuration Test**:
  ```bash
  docker exec -it nginx nginx -t
  ```

- **Inspect Internal Bridge Network**:
  ```bash
  docker network inspect inception_network
  ```

---

## 4. Persistent Storage Architecture & Data Flow

### Host Path Binding
Persistence is handled through host bind mounts configured in `srcs/docker-compose.yml`:

| Volume Name | Container Mount Target | Host Storage Path | Contents |
| :--- | :--- | :--- | :--- |
| `wordpress_data` | `/var/www/wordpress` | `/home/abdouahi/data/wordpress` | WordPress PHP source code, `wp-config.php`, plugins, themes, uploads. |
| `mariadb_data` | `/var/lib/mysql` | `/home/abdouahi/data/mariadb` | InnoDB database datafiles, system tables, transaction logs. |

### Data Lifecycle
1. **Container Re-creation**: If a container crashes or is deleted via `docker rm`, restarting it with `make up` re-attaches the persistent volumes instantly with no data loss.
2. **First Boot Initialization**:
   - `mariadb_setup.sh` checks if `/var/lib/mysql/mysql` exists. If not, it executes `mariadb-install-db` and provisions users.
   - `wp_setup.sh` checks if `/var/www/wordpress/index.php` and `wp-config.php` exist. If not, it downloads the core and installs WordPress automatically.
3. **Complete Purge**: Running `make fclean` will delete the host directories in `/home/abdouahi/data/`, allowing a completely fresh installation from scratch.
