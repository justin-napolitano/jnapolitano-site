# Makefile
SHELL := /bin/bash

IMAGE ?= ghcr.io/justin-napolitano/jnapolitano-blog:latest

# Mode: dev or prod
MODE ?= prod

# Base URLs per mode
DEV_BASE_URL  ?= http://192.168.1.115:8082
PROD_BASE_URL ?= https://jnapolitano.com

# Resolve base URL from MODE
BASE_URL := $(if $(filter $(MODE),dev),$(DEV_BASE_URL),$(PROD_BASE_URL))

.PHONY: build rebuild up up-dev up-prod rebuild-dev rebuild-prod run logs down push clean print

## Build using docker compose, passing Zola base_url
build:
	@echo ">> building ($(MODE)) with ZOLA_BASE_URL=$(BASE_URL)"
	docker compose build --build-arg ZOLA_BASE_URL=$(BASE_URL)

## Build from scratch, pull fresh bases
rebuild:
	@echo ">> rebuilding ($(MODE)) no-cache with ZOLA_BASE_URL=$(BASE_URL)"
	docker compose build --no-cache --pull --build-arg ZOLA_BASE_URL=$(BASE_URL)

## Bring it up (uses current MODE)
up: build
	docker compose up -d --force-recreate

## Convenience: dev/prod aliases so you don't whine about args
up-dev:
	$(MAKE) up MODE=dev

up-prod:
	$(MAKE) up MODE=prod

rebuild-dev:
	$(MAKE) rebuild MODE=dev
	docker compose up -d --force-recreate

rebuild-prod:
	$(MAKE) rebuild MODE=prod
	docker compose up -d --force-recreate

## Run the already-built image directly (bypasses compose)
run:
	docker run --rm -p 8082:80 $(IMAGE)

logs:
	docker compose logs -f

down:
	docker compose down --remove-orphans

## Push multi-arch PROD image (prod base_url baked in)
push:
	docker buildx create --use --name multi || true
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--build-arg ZOLA_BASE_URL=$(PROD_BASE_URL) \
		-t $(IMAGE) --push .

## Debug what you're actually building
print:
	@echo MODE=$(MODE)
	@echo BASE_URL=$(BASE_URL)
	@echo IMAGE=$(IMAGE)
