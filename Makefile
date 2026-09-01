NAME = inception

COMPOSE_FILE = ./srcs/docker-compose.yml
ENV_FILE = ./srcs/.env
DATA_DIR_WP = /home/abdo/data/wordpress
DATA_DIR_DB = /home/abdo/data/mariadb

# Use docker compose if available, fallback to docker-compose
DOCKER_COMPOSE = $(shell which docker-compose 2>/dev/null || echo "docker compose")

all: build up

init_dirs:
	@mkdir -p $(DATA_DIR_WP) $(DATA_DIR_DB)

build: init_dirs
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) build

up: init_dirs
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up -d

down:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down

stop:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) stop

start:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) start

status ps:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) ps

logs:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) logs -f

clean: down
	@docker stop $$(docker ps -qa) 2>/dev/null || true
	@docker rm $$(docker ps -qa) 2>/dev/null || true
	@docker network rm inception_network 2>/dev/null || true

fclean: clean
	@docker rmi -f $$(docker images -qa) 2>/dev/null || true
	@docker volume rm $$(docker volume ls -q) 2>/dev/null || true
	@docker system prune -a --volumes -f 2>/dev/null || true
	@sudo rm -rf $(DATA_DIR_WP) $(DATA_DIR_DB) 2>/dev/null || rm -rf $(DATA_DIR_WP) $(DATA_DIR_DB) 2>/dev/null || true

re: fclean all

.PHONY: all build up down stop start status ps logs clean fclean re init_dirs
