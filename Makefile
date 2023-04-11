.PHONY: all
all: build

.PHONY: build
build:
	docker buildx build \
		--platform=linux/amd64,linux/arm,linux/arm64 \
		--build-arg TOR_VERSION=0.4.7.13 \
		--tag quay.io/bugfest/tor:0.4.7.13 \
		--tag quay.io/bugfest/tor:latest \
		--squash \
		.

.PHONY: build-alt
build-alt:
	docker buildx build \
		--platform=linux/amd64,linux/arm,linux/arm64 \
		--build-arg TOR_VERSION=0.4.7.13 \
		--tag quay.io/bugfest/tor:0.4.7.13 \
		--tag quay.io/bugfest/tor:latest \
		--squash \
		-f Dockerfile.build .