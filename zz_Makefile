IMAGE ?= ghcr.io/justin-napolitano/jnapolitano-blog:latest

build:
	docker build -t $(IMAGE) .

run:
	docker run --rm -p 8082:80 $(IMAGE)

up:
	docker compose up --build -d

logs:
	docker compose logs -f

push:
	docker buildx create --use --name multi || true
	docker buildx build --platform linux/amd64,linux/arm64 -t $(IMAGE) --push .
