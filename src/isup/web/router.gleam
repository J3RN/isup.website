//// I'm not especially fond of router modules. IMO, controllers should define
//// the routes they serve, a la how Spring does it. However, that would require
//// the served routes to be aggregated somehow at compile-time and I don't know
//// of any way to do that presently.
//// Also all controller-type actions are defined in here seeing as there's only
//// two.

// External
import wisp.{type Request, type Response}

// Stdlib
import gleam/bit_array
import gleam/result.{try}
import gleam/string
import gleam/uri

// Application
import isup/checker.{Down, Moved, Up}

// Templates
import isup/web/templates/down
import isup/web/templates/fail
import isup/web/templates/form
import isup/web/templates/layout
import isup/web/templates/moved
import isup/web/templates/not_found
import isup/web/templates/success

pub fn route(req: Request) -> Response {
  case wisp.path_segments(req) {
    [] -> index(req)
    ["lookup"] -> lookup(req)
    _ -> not_found(req)
  }
}

fn index(_req) {
  form.render()
  |> html_response(200)
}

fn lookup(req: Request) -> Response {
  let host =
    req
    |> wisp.read_body_bits()
    |> try(bit_array.to_string)
    |> try(uri.percent_decode)
    |> try(get_host)

  case host {
    Ok(host) -> check(host)
    Error(Nil) -> html_response(fail.render(), 400)
  }
}

fn check(host) {
  wisp.log_info("Checking: " <> host)
  case checker.lookup(host) {
    Ok(Up) -> html_response(success.render(url: host), 200)
    Ok(Moved(new_url)) ->
      html_response(moved.render(url: host, new_location: new_url), 200)
    Ok(Down) -> html_response(down.render(url: host), 200)
    Error(_) -> html_response(fail.render(), 400)
  }
}

fn get_host(body_string) {
  case string.split_once(body_string, on: "=") {
    Ok(#("url", host)) -> Ok(host)
    _ -> Error(Nil)
  }
}

fn not_found(_req) {
  not_found.render()
  |> html_response(404)
}

fn html_response(content, status) {
  content
  |> layout.render()
  |> wisp.html_response(status)
}
