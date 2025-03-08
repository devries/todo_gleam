FROM ghcr.io/gleam-lang/gleam:v1.8.1-erlang-alpine AS build

RUN apk update && apk add build-base
WORKDIR /builder
COPY . /builder/

RUN gleam export erlang-shipment

FROM erlang:alpine
VOLUME /data
COPY --from=build /builder/build/erlang-shipment /app
WORKDIR /app
ENV DBFILE=/data/todo.db
ENTRYPOINT ["/app/entrypoint.sh", "run"]
CMD []
