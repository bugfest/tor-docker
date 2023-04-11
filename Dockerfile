ARG ALPINE_VERSION="3.17"

# Build the obfs4 binary (cross-compiling)
FROM --platform=$BUILDPLATFORM golang:1.17-alpine as obfs-builder
ARG OBFS_VERSION="obfs4proxy-0.0.14-tor2"

RUN apk add --update --no-cache git
RUN git clone https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/obfs4.git --depth 1 --branch $OBFS_VERSION /obfs

# Build obfs
RUN mkdir /out
WORKDIR /obfs
ARG TARGETOS TARGETARCH
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /out/obfs4proxy ./obfs4proxy

# Tor runner
FROM --platform=$TARGETPLATFORM docker.io/library/alpine:$ALPINE_VERSION as runner

LABEL \
      org.opencontainers.image.source "https://github.com/bugfest/tor-docker"

WORKDIR /app

RUN apk add --update --no-cache \
      tor && \
    chmod -R g+w .

# install transports
COPY --from=obfs-builder /out/obfs4proxy /usr/local/bin/.

USER 1001

ENTRYPOINT ["tor"]
