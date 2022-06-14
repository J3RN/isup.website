// External
import gleam/erlang
import gleam/erlang/os
import gleam/otp/supervisor
import mist
// Stdlib
import gleam/int
import gleam/io
import gleam/result.{then, unwrap}
import gleam/string
// Application
import isup/web/endpoint

pub fn main() {
  let port =
    os.get_env("PORT")
    |> then(int.parse)
    |> unwrap(3000)

  case start_supervision(port) {
    Ok(_) -> {
      io.println(string.append(
        "Listening on https://localhost:",
        int.to_string(port),
      ))
      erlang.sleep_forever()
    }
    Error(_) -> io.println("Failed to start server. Exiting.")
  }
}

fn start_supervision(port) {
  supervisor.start(fn(children) {
    supervisor.add(
      children,
      supervisor.worker(fn(_arg) { mist.run_service(port, endpoint.handle) }),
    )
  })
}
