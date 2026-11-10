COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/abdouahi/data

all: up

init_dirs:
	mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress

up: init_dirs
	docker compose -f $(COMPOSE_FILE) up --build -d

down:
	docker compose -f $(COMPOSE_FILE) down

clean:
	docker compose -f $(COMPOSE_FILE) down --remove-orphans

fclean:
	docker compose -f $(COMPOSE_FILE) down --rmi local --volumes --remove-orphans

re: fclean up

.PHONY: all init_dirs up down clean fclean re
