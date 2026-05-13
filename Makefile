.PHONY: up down logs

COMPOSE := $(shell docker compose version >/dev/null 2>&1 && echo "docker compose" || echo "podman compose")

up:
	$(COMPOSE) up -d
	bash socket_fix.sh

down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f
