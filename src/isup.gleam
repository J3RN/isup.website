// External
import gleam/hackney
import gleam/erlang
import gleam/http/elli
import gleam/http.{Get, Post, Request, Response}
// Stdlib
import gleam/bit_builder.{BitBuilder}
import gleam/bit_string
import gleam/option.{None, Option, Some}
import gleam/result.{map, then, unwrap}
import gleam/string
import gleam/int
import gleam/io
import gleam/uri.{Uri}

type Status {
  Up
  Moved(new_url: Option(String))
  Down
}

pub fn main() {
  let port =
    get_env("PORT")
    |> then(int.parse)
    |> unwrap(3000)

  elli.start(endpoint, on_port: port)
  io.println(string.append(
    "Listening on https://localhost:",
    int.to_string(port),
  ))
  erlang.sleep_forever()
}

fn endpoint(req: Request(BitString)) -> Response(BitBuilder) {
  case router(req) {
    Ok(resp) -> resp
    Error(_) -> {
      let message = bit_builder.from_string("Internal Server Error")
      http.response(500)
      |> http.set_resp_body(message)
    }
  }
}

fn router(req) -> Result(Response(BitBuilder), Nil) {
  case req {
    Request(method: Get, path: "/", ..) -> index(req)
    Request(method: Post, path: "/lookup", ..) -> lookup(req)
    _ -> not_found(req)
  }
}

fn index(_req) {
  "
  <html>
    <head>
      <meta charset=\"utf-8\">
    </head>
    <body>
      <h1>Is it up?</h1>
      <form method='post' action='/lookup'>
        <input type=\"text\" name=\"url\" placeholder=\"https://gleam.run\" />
        <button>Check</button>
      </form>
    </body>
  </html>
  "
  |> html_response(200, _)
}

fn lookup(req) {
  try body_string = bit_string.to_string(req.body)
  try host =
    case string.split(body_string, "=") {
      ["url", host] -> Ok(host)
      _ -> Error(Nil)
    }
    |> then(uri.percent_decode)
    |> then(extract_host)

  case is_up(host) {
    Up ->
      "
      <html>
        <head>
          <meta charset=\"utf-8\">
        </head>
        <body>
          <h1>It is up!</h1>
          <a href=\"/\">← Try again</a>
        </body>
      </html>
      "
    Moved(_uri) ->
      "
      <html>
        <head>
          <meta charset=\"utf-8\">
        </head>
        <body>
          <h1>The page has been moved!</h1>
          <a href=\"/\">← Try again</a>
        </body>
      </html>
      "
    Down ->
      "
      <html>
        <head>
          <meta charset=\"utf-8\">
        </head>
        <body>
          <h1>It is down!</h1>
          <a href=\"/\">← Try again</a>
        </body>
      </html>
      "
  }
  |> html_response(200, _)
}

// TODO: uri.parse considers URIs such as "j3rn.com" to be completely path
// Also accepts raw words like "cat" as above
pub fn extract_host(host) {
  case uri.parse(host) {
    Ok(Uri(host: Some(host), ..)) -> Ok(host)
    _ -> Error(Nil)
  }
}

fn not_found(_req) {
  "
  <html>
    <body>
      <h1>You're lost!</h1>
    </body>
  </html>
  "
  |> html_response(404, _)
}

fn is_up(host) {
  let req =
    http.default_req()
    |> http.set_host(host)

  case hackney.send(req) {
    Ok(Response(status: 200, ..)) -> Up
    Ok(Response(status: status, ..)) if status >= 300 && status < 400 ->
      Moved(None)
    Error(_) -> Down
  }
}

fn html_response(status, content) {
  let body = bit_builder.from_string(content)

  http.response(status)
  |> http.prepend_resp_header("Content-Type", "text/html")
  |> http.set_resp_body(body)
  |> Ok()
}

// Replace when `env.get` makes it into gleam/erlang
external fn get_env(name: String) -> Result(String, Nil) =
  "gleam_env" "get"
