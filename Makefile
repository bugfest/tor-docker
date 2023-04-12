.PHONY: all
all: build

.PHONY: quick
build:
	docker buildx build \
		--platform=linux/amd64,linux/arm,linux/arm64 \
		--build-arg ALPINE_VERSION=3.17.3 \
		--build-arg TOR_VERSION=0.4.7.13 \
		--tag quay.io/bugfest/tor:0.4.7.13 \
		--tag quay.io/bugfest/tor:latest \
		--squash \
		-f Dockerfile.quick \
		.

.PHONY: build
build-alt:
	docker buildx build \
		--platform=linux/amd64,linux/arm,linux/arm64 \
		--build-arg ALPINE_VERSION=3.17.3 \
		--build-arg TOR_VERSION=0.4.7.13 \
		--tag quay.io/bugfest/tor:0.4.7.13 \
		--tag quay.io/bugfest/tor:latest \
		--squash \
		-f Dockerfile \
		.
