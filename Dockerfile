ARG ALPINE_VERSION="3.17"

# Tor builder
FROM --platform=$BUILDPLATFORM alpine:$ALPINE_VERSION as tor-builder

ARG TOR_VERSION="0.4.7.13"
RUN apk add --update --no-cache git build-base automake autoconf make build-base openssl-dev libevent-dev zlib-dev

# Install Tor from source
RUN git clone https://gitlab.torproject.org/tpo/core/tor.git --depth 1 --branch tor-$TOR_VERSION /tor
WORKDIR /tor
RUN ./autogen.sh
RUN ./configure --disable-asciidoc
RUN make
RUN make install

# Clone the obfs4 repo
FROM --platform=$BUILDPLATFORM golang:1.17-alpine as obfs-src
ARG OBFS_VERSION="obfs4proxy-0.0.14-tor2"

RUN apk add git
RUN git clone https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/obfs4.git --depth 1 --branch $OBFS_VERSION /obfs

# Build the obfs4 binary
FROM --platform=$BUILDPLATFORM golang:1.17-alpine as obfs-builder

# Build obfs
RUN mkdir /out
WORKDIR /obfs
RUN --mount=target=. \
    --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg \
    --mount=type=bind,from=obfs-src,source=/obfs,target=/obfs \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /out/obfs4proxy ./obfs4proxy

# Tor runner
FROM --platform=$BUILDPLATFORM alpine:$ALPINE_VERSION as runner
WORKDIR /root/

RUN apk add --update --no-cache libevent

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
RUN mkdir -p /run/tor/service

ENTRYPOINT ["/usr/local/bin/tor"]
