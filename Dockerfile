ARG ALPINE_VERSION="3.15"
FROM alpine:$ALPINE_VERSION as tor-builder

ARG TOR_VERSION="0.4.6.8"
RUN apk update
RUN apk add --no-cache git build-base automake autoconf make build-base openssl-dev libevent-dev zlib-dev

# Install Tor from source
RUN git clone https://gitlab.torproject.org/tpo/core/tor.git --depth 1 --branch tor-$TOR_VERSION /tor
WORKDIR /tor
RUN ./autogen.sh
RUN ./configure --disable-asciidoc
RUN make
RUN make install

FROM alpine:$ALPINE_VERSION
WORKDIR /root/

RUN apk update
RUN apk add --no-cache libevent \
    && rm -rf /var/cache/apk/*

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

# create service dir
RUN mkdir -p /run/tor/service

ENTRYPOINT ["/usr/local/bin/tor"]
