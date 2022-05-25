FROM ghcr.io/gleam-lang/gleam:v0.21.0-erlang-alpine as builder

WORKDIR /app

ADD . /app

RUN gleam build

CMD ["gleam", "run"]
