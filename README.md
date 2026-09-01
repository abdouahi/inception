*This project has been created as part of the 42 curriculum by abdouahi.*

# Inception - System Administration & Docker Infrastructure

## Description
The **Inception** project is a core system administration challenge in the 42 curriculum designed to deepen understanding of virtualization, containerization, and secure service architecture using **Docker** and **Docker Compose**.

The project establishes a secure, robust, and isolated multi-container LEMP-like stack without relying on pre-built application images from Docker Hub. Every service image is built from scratch using custom `Dockerfile`s based on the penultimate stable release of Debian (**Debian Bullseye**).

### Architectural Stack
- **NGINX**: Secure reverse proxy and TLS termination gateway on port `443` (TLSv1.2/1.3 only).
- **WordPress + PHP-FPM**: Dynamic application engine handling WordPress execution over FastCGI (port `9000`).
- **MariaDB**: Relational database storage accessible exclusively within the internal docker network (port `3306`).
- **Docker Volumes**: Host-bound persistent storage paths (`/home/abdo/data/wordpress` and `/home/abdo/data/mariadb`).
- **Docker Network**: Custom isolated bridge network (`inception_network`) connecting all services.

---

## Instructions

### Prerequisites
- Operating System: Linux / Virtual Machine (Debian/Ubuntu) or WSL2.
- Packages: `docker`, `docker-compose` (or Docker Compose v2 plugin), `make`.
- Host resolution: Map `abdouahi.42.fr` to `127.0.0.1` in `/etc/hosts`.

```bash
# Add domain resolution to /etc/hosts
echo "127.0.0.1 abdouahi.42.fr" | sudo tee -a /etc/hosts
```

### Installation and Execution

1. **Build and Launch Infrastructure**:
   ```bash
   make
   # or
   make all
   ```

2. **Check Status of Containers**:
   ```bash
   make status
   ```

3. **View Live Logs**:
   ```bash
   make logs
   ```

4. **Access the Application**:
   - Website: [https://abdouahi.42.fr](https://abdouahi.42.fr)
   - WordPress Admin Dashboard: [https://abdouahi.42.fr/wp-login.php](https://abdouahi.42.fr/wp-login.php)

5. **Stop and Clean**:
   ```bash
   # Stop services
   make down

   # Remove containers and networks
   make clean

   # Complete reset (removes images, volumes, and persistent data)
   make fclean

   # Full rebuild
   make re
   ```

---

## Resources & AI Usage

### References & Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose File Specification](https://docs.docker.com/compose/compose-file/)
- [NGINX Official Documentation & SSL Termination](https://nginx.org/en/docs/)
- [WP-CLI Handbook](https://make.wordpress.org/cli/handbook/)
- [MariaDB Server Documentation](https://mariadb.com/kb/en/documentation/)

### AI Usage Description
In compliance with 42 AI guidelines:
- **Architecture Planning**: AI assisted in drafting the multi-service dependency chain, ensuring strict non-root privilege handling, and verifying compliance with version 5.0 subject constraints.
- **Troubleshooting & Shell Optimization**: AI helped verify POSIX-compliant scripting patterns for initialization scripts (`wp_setup.sh`, `mariadb_setup.sh`) to eliminate race conditions and avoid prohibited PID 1 antipatterns (`tail -f`, infinite loops).
- **Comparative Analysis & Documentation**: AI was utilized to structure and cross-reference theoretical comparisons between containerization models, secret management strategies, networking modes, and storage paradigms.

---

## Project Description & Technical Design Choices

### 1. Virtual Machines vs Docker
| Feature | Virtual Machines (VM) | Docker Containers |
| :--- | :--- | :--- |
| **Architecture** | Runs a complete guest OS on virtualized hardware via Hypervisor (Type 1 or Type 2). | Shares the host Linux kernel and isolates processes via namespaces & cgroups. |
| **Resource Overhead** | High (memory, CPU, and disk pre-allocated per VM). | Extremely lightweight (minimal overhead, fast startup in seconds/milliseconds). |
| **Isolation** | Strong hardware-level isolation. | Kernel-level process isolation. |
| **Use Case** | Running heterogeneous OS kernels or untrusted multitenancy. | Microservices, rapid scaling, uniform CI/CD environments. |

### 2. Secrets vs Environment Variables
- **Environment Variables**:
  - Readily accessible to any process within the container or inspectable via `docker inspect`.
  - Suitable for non-sensitive configuration such as domain names, database names, listening ports, or debug flags.
- **Docker Secrets**:
  - Mounted as in-memory tmpfs files (`/run/secrets/...`), keeping sensitive values out of container inspection metadata, build logs, and commit histories.
  - Essential for database passwords, root credentials, and application administrative passwords.

### 3. Docker Network vs Host Network
- **Docker Custom Bridge Network (`inception_network`)**:
  - Provides network segmentation and automatic DNS resolution by container name (`mariadb`, `wordpress`, `nginx`).
  - Strict port isolation: database (3306) and FastCGI (9000) remain strictly private and unreachable from the external host network.
- **Host Network (`network_mode: host`)**:
  - Bypasses Docker network virtualization, binding container ports directly to host interfaces.
  - Breaks encapsulation and multi-container port isolation (hence strictly forbidden in the subject).

### 4. Docker Volumes vs Bind Mounts
- **Docker Named Volumes**:
  - Managed entirely by the Docker daemon in `/var/lib/docker/volumes/`, offering lifecycle decoupling from host directory structures.
- **Bind Mounts**:
  - Directly maps specific host paths (such as `/home/abdo/data/wordpress` and `/home/abdo/data/mariadb`) into container filesystems.
  - Ensures direct host-level inspection, persistent survival across container re-creations, and explicit storage locality mandated by the 42 subject.
