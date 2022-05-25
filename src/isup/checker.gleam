// External
import gleam/hackney
import gleam/http.{Response}
// Stdlib
import gleam/bit_string
import gleam/list
import gleam/io
import gleam/option.{None, Option, Some}
import gleam/result
import gleam/string
import gleam/uri.{Uri}

pub type Status {
  Up
  Moved(new_url: Option(String))
  Down
}

pub fn lookup(url: String) -> Result(Status, Nil) {
  extract_host(url)
  |> result.map(is_up)
}

fn extract_host(host) {
  let host = case bit_string.from_string(host) {
    <<"http":utf8, _:bit_string>> -> host
    _ -> string.append("https://", host)
  }

  case uri.parse(host) {
    Ok(Uri(host: Some(host), ..)) -> Ok(host)
    _ -> Error(Nil)
  }
}

fn is_up(host) {
  let req =
    http.default_req()
    |> http.set_host(host)

  case hackney.send(req) {
    Ok(Response(status: 200, ..)) -> Up
    Ok(Response(status: status, headers: headers, ..)) if status >= 300 && status < 400 ->
      case list.find(headers, fn(header) { header.0 == "location" }) {
        Ok(header) -> Moved(Some(header.1))
        Error(Nil) -> Moved(None)
      }
    Error(_) -> Down
  }
}
