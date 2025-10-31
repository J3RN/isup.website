// External
import envoy
import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist

// Stdlib
import gleam/int
import gleam/io
import gleam/result.{try, unwrap}
import gleam/string

// Application
import isup/web/endpoint

pub fn main() {
  let port =
    envoy.get("PORT")
    |> try(int.parse)
    |> unwrap(3000)

  wisp.configure_logger()

  let secret_key_base = wisp.random_string(64)

  let assert Ok(_) =
    wisp_mist.handler(endpoint.handle, secret_key_base)
    |> mist.new
    |> mist.port(port)
    |> mist.start

  io.println(string.append(
    "Listening on https://localhost:",
    int.to_string(port),
  ))

  process.sleep_forever()
}
