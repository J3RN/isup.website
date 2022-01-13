FROM ghcr.io/gleam-lang/gleam:v0.19.0-erlang as builder

WORKDIR /app

ADD . /app

RUN gleam build

CMD ["gleam", "run"]
