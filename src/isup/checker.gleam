// External
import gleam/hackney
import gleam/http/request
import gleam/http/response.{Response}

// Stdlib
import gleam/bit_array
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/uri.{Uri}

pub type Status {
  Up
  Moved(new_url: Option(String))
  Down
}

pub fn lookup(url: String) -> Result(Status, Nil) {
  url
  |> extract_host
  |> result.map(is_up)
}

fn extract_host(host) {
  let host = case bit_array.from_string(host) {
    <<"http":utf8, _:bits>> -> host
    _ -> "https://" <> host
  }

  case uri.parse(host) {
    Ok(Uri(scheme: Some(scheme), host: Some(host), ..)) ->
      Ok(scheme <> "://" <> host)
    Ok(Uri(scheme: None, host: Some(host), ..)) -> Ok("https://" <> host)
    _ -> Error(Nil)
  }
}

fn is_up(host) {
  let assert Ok(req) = request.to(host)

  case hackney.send(req) {
    Ok(Response(status: 200, ..)) -> Up
    Ok(Response(status: status, headers: headers, ..))
      if status >= 300 && status < 400
    ->
      case list.find(headers, fn(header) { header.0 == "location" }) {
        Ok(header) -> Moved(Some(header.1))
        Error(Nil) -> Moved(None)
      }
    _ -> Down
  }
}
