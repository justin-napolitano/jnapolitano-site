# syntax=docker/dockerfile:1

############################
# Builder (glibc/gnu)      #
############################
FROM debian:bookworm-slim AS builder
ARG ZOLA_VERSION=v0.19.2
ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates tar \
  && rm -rf /var/lib/apt/lists/*

# Map Docker arch -> Zola triple (gnu, not musl)
RUN case "$TARGETARCH" in \
      amd64)  PKG="zola-${ZOLA_VERSION}-x86_64-unknown-linux-gnu.tar.gz" ;; \
      arm64)  PKG="zola-${ZOLA_VERSION}-aarch64-unknown-linux-gnu.tar.gz" ;; \
      *) echo "Unsupported arch: $TARGETARCH" && exit 1 ;; \
    esac \
 && curl -fsSLO "https://github.com/getzola/zola/releases/download/${ZOLA_VERSION}/${PKG}" \
 && tar -xzf "$PKG" zola \
 && install -m0755 zola /usr/local/bin/zola

WORKDIR /site
COPY ./site/ /site/
RUN zola build

############################
# Runtime (static files)   #
############################
FROM caddy:2-alpine
COPY --from=builder /site/public /usr/share/caddy
COPY Caddyfile /etc/caddy/Caddyfile
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -qO- http://localhost/ >/dev/null || exit 1
