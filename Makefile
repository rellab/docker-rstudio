# Variables
IMAGE_NAME := rellab/docker-rstudio
TAG := latest
DOCKER_REGISTRY := ghcr.io
FULL_IMAGE := $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(TAG)

# GitHub credentials (must be passed as environment variables)
GITHUB_USER ?= 
GITHUB_TOKEN ?= 

.PHONY: all build push clean login

all: build

# Build multi-arch image
build:
	docker buildx build --platform linux/amd64,linux/arm64 -t $(FULL_IMAGE) --push .

# Optional login
login:
	@if [ -z "$(GITHUB_USER)" ] || [ -z "$(GITHUB_TOKEN)" ]; then \
	  echo "Error: GITHUB_USER and GITHUB_TOKEN must be set"; \
	  exit 1; \
	fi
	echo "$(GITHUB_TOKEN)" | docker login $(DOCKER_REGISTRY) -u $(GITHUB_USER) --password-stdin

# Push is now part of buildx build --push, so this is optional
push: login build

clean:
	docker image prune -f

