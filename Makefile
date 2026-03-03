# Get user and group IDs
USER_UID := $(shell id -u)
USER_GID := $(shell id -g)

# Export them so they are available in docker-compose
export USER_UID
export USER_GID

# Default target
.DEFAULT_GOAL := help

# Colors for help messages
YELLOW := \033[33m
NC := \033[0m # No Color

.PHONY: help build up down stop restart shell logs

## Display help message
help:
	@echo "${YELLOW}Usage:${NC}"
	@echo "  make [target]"
	@echo ""
	@echo "${YELLOW}Targets:${NC}"
	@awk '/^[a-zA-Z\-\_0-9\.]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-20s${NC} %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

## Build project containers
build:
	USER_UID=$(USER_UID) USER_GID=$(USER_GID) docker compose build --pull

## Start project containers in detached mode
up:
	USER_UID=$(USER_UID) USER_GID=$(USER_GID) docker compose up --remove-orphans

## Stop project containers
stop:
	docker compose stop

## Stop and remove project containers
down:
	docker compose down --remove-orphans

## Restart project containers
restart: down up

## Enter PHP container as current user
shell:
	docker compose exec --user "$(USER_UID):$(USER_GID)" php bash

## Follow project logs
logs:
	docker compose logs -f

## Run tests in PHP container
test:
	docker compose exec --user "$(USER_UID):$(USER_GID)" php bin/phpunit

## Install composer dependencies
install:
	docker compose exec --user "$(USER_UID):$(USER_GID)" php composer install

## Update composer dependencies
update:
	docker compose exec --user "$(USER_UID):$(USER_GID)" php composer update
