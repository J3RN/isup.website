FROM ghcr.io/gleam-lang/gleam:v1.13.0-erlang-alpine as builder

WORKDIR /app

ADD . /app

RUN gleam build

EXPOSE 3000

CMD ["gleam", "run"]
