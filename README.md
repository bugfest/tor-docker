<h1 align="center"><b>tor-docker</b></h1>


[![Build multiarch image - latest](https://github.com/bugfest/tor-docker/actions/workflows/main.yml/badge.svg)](https://github.com/bugfest/tor-docker/actions/workflows/main.yml)
[![Build multiarch image - tag](https://github.com/bugfest/tor-docker/actions/workflows/main-tag.yml/badge.svg)](https://github.com/bugfest/tor-docker/actions/workflows/main-tag.yml)

`Tor` daemon (https://www.torproject.org/download/tor/) multiarch container.

Additional transport plugins included in the image:
- `obfs4proxy`

Tested architectures:

- `amd64`
- `arm`
- `arm64`

Source code:
- https://gitlab.torproject.org/tpo/core/tor
- https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/obfs4

Used by:
- [bugfest/tor-controller](https://github.com/bugfest/tor-controller)

# Tor

Tor is an anonymity network that provides:

- privacy
- enhanced tamperproofing
- freedom from network surveillance
- NAT traversal

## How to

## Standard build

Builds Tor from source. Method used to create releases in this repo.

```bash
make
```

## Quick build

Installs pre-built Tor from Alpine's repositories. Useful for testing/troubleshooting.

```bash
make quick
```

# Usage

```shell
docker pull quay.io/bugfest/tor
```
