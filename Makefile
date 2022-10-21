# The version that will be used in docker tags (e.g. to push a
# kafka-lite:latest image use `make imagepush VERSION=latest)`
VERSION    ?= $(shell git rev-parse --short HEAD)
DOCKER_TAG ?= mccutchen/kafka-lite:$(VERSION)

build:
	DOCKER_BUILDKIT=1 docker build -t $(DOCKER_TAG) .
.PHONY: image

release:
	docker buildx inspect kafka-lite &>/dev/null || docker buildx create --name kafka-lite
	docker buildx build --builder kafka-lite --push --platform linux/amd64,linux/arm64 -t $(DOCKER_TAG) .
.PHONY: release
