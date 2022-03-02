.PHONY: all
all: build

.PHONY: build
build:
	docker buildx build \
		--platform=linux/amd64,linux/arm,linux/arm64 \
		--build-arg TOR_VERSION=0.4.6.10 \
		--tag quay.io/bugfest/tor:0.4.6.10 \
		--tag quay.io/bugfest/tor:latest \
		.

