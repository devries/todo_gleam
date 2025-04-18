FROM ghcr.io/gleam-lang/gleam:v1.9.1-erlang-alpine AS build

RUN apk update && apk add build-base
WORKDIR /builder
COPY gleam.toml manifest.toml /builder/
COPY src/ /builder/src/
COPY priv/ /builder/priv/

RUN gleam export erlang-shipment
RUN sed -i 's/\berl\b/exec\ erl/g' build/erlang-shipment/entrypoint.sh

FROM erlang:alpine
VOLUME /data
COPY --from=build /builder/build/erlang-shipment /app
WORKDIR /app
ENV DBFILE=/data/todo.db
COPY waitrun.sh /app/waitrun.sh
# ENTRYPOINT ["/app/entrypoint.sh", "run"]
ENTRYPOINT ["/app/waitrun.sh"]
CMD []
