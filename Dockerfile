FROM debian:13-slim AS tailwind
ARG TARGETOS TARGETARCH
WORKDIR /builder
RUN apt-get -y update && apt-get -y install curl

RUN if [ "$TARGETARCH" = "arm64" ]; then \
  curl -sL -o tailwindcss https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-linux-arm64; \
  else \
  curl -sL -o tailwindcss  https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-linux-x64; \
  fi; \
  chmod ugo+x tailwindcss

COPY src/ /builder/src/
COPY input.css /builder/input.css
RUN ./tailwindcss -i input.css -o main.css --minify

FROM ghcr.io/gleam-lang/gleam:v1.13.0-erlang-alpine AS build

RUN apk update && apk add build-base
WORKDIR /builder
COPY gleam.toml manifest.toml /builder/
COPY src/ /builder/src/
COPY priv/ /builder/priv/
COPY --from=tailwind /builder/main.css /builder/priv/static/main.css

RUN gleam export erlang-shipment
# Fixed in 1.11.0
# RUN sed -i 's/\berl\b/exec\ erl/g' build/erlang-shipment/entrypoint.sh

FROM erlang:alpine
VOLUME /data
COPY --from=build /builder/build/erlang-shipment /app
WORKDIR /app
ENV DBFILE=/data/todo.db
ENV ERL_AFLAGS=+B
COPY waitrun.sh /app/waitrun.sh
# ENTRYPOINT ["/app/entrypoint.sh", "run"]
ENTRYPOINT ["/app/waitrun.sh"]
CMD []
