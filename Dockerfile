ARG ALPINE_VERSION="3.17.3"

# Tor builder
FROM --platform=$TARGETPLATFORM docker.io/library/alpine:$ALPINE_VERSION as tor-builder

ARG TOR_VERSION="0.4.7.13"
RUN apk add --update --no-cache \
    git build-base automake autoconf make \
    build-base openssl-dev libevent-dev zlib-dev \
    xz-dev zstd-dev

# Install Tor from source
RUN git clone https://gitlab.torproject.org/tpo/core/tor.git --depth 1 --branch tor-$TOR_VERSION /tor
WORKDIR /tor
RUN ./autogen.sh
RUN ./configure \
    --disable-asciidoc \
    --disable-manpage \
    --disable-html-manual
    # --enable-static-tor
RUN make
RUN make install

# Build the obfs4 binary (cross-compiling)
FROM --platform=$BUILDPLATFORM golang:1.20-alpine as obfs-builder
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

RUN apk add --update --no-cache libevent && \
    chmod -R g+w /app /run

# install tor
RUN mkdir -p /usr/local/bin /usr/local/etc/tor /usr/local/share/tor
COPY --from=tor-builder /usr/local/bin/tor /usr/local/bin/tor
COPY --from=tor-builder /tor/src/tools/tor-resolve /usr/local/bin/.
COPY --from=tor-builder /tor/src/tools/tor-print-ed-signing-cert /usr/local/bin/.
COPY --from=tor-builder /tor/src/tools/tor-gencert /usr/local/bin/.
COPY --from=tor-builder /tor/contrib/client-tools/torify /usr/local/bin/.
COPY --from=tor-builder /tor/src/config/torrc.sample /usr/local/etc/tor/.
COPY --from=tor-builder /tor/src/config/geoip /usr/local/share/tor/.
COPY --from=tor-builder /tor/src/config/geoip6 /usr/local/share/tor/.

# install transports
COPY --from=obfs-builder /out/obfs4proxy /usr/local/bin/.

# create service dir
RUN mkdir -p /run/tor/service && \
    chmod -R g+w /run

USER 1001

ENTRYPOINT ["/usr/local/bin/tor"]
