.PHONY: up down logs

up:
	docker-compose up -d
	bash socket_fix.sh

down:
	docker-compose down

logs:
	docker-compose logs -f
