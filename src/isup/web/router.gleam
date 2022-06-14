//// I'm not especially fond of router modules. IMO, controllers should define
//// the routes they serve, a la how Spring does it. However, that would require
//// the served routes to be aggregated somehow at compile-time and I don't know
//// of any way to do that presently.
//// Also all controller-type actions are defined in here seeing as there's only
//// two.

// External
import gleam/http.{Get, Post}
import gleam/http/request.{Request}
import gleam/http/response.{Response}
// Stdlib
import gleam/bit_builder.{BitBuilder}
import gleam/bit_string
import gleam/result.{then}
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

pub fn route(req: Request(BitString)) -> Response(BitBuilder) {
  case req {
    Request(method: Get, path: "/", ..) -> index(req)
    Request(method: Post, path: "/lookup", ..) -> lookup(req)
    _ -> not_found(req)
  }
}

fn index(_req) {
  form.render()
  |> html_response(200, _)
}

fn lookup(req) {
  let host =
    bit_string.to_string(req.body)
    |> then(get_host)
    |> then(uri.percent_decode)

  case host {
    Ok(host) -> check(host)
    Error(_) -> html_response(400, fail.render())
  }
}

fn check(host) {
  case checker.lookup(host) {
    Ok(Up) -> html_response(200, success.render(url: host))
    Ok(Moved(new_url)) ->
      html_response(200, moved.render(url: host, new_location: new_url))
    Ok(Down) -> html_response(200, down.render(url: host))
    Error(_) -> html_response(400, fail.render())
  }
}

fn get_host(body_string) {
  case string.split(body_string, "=") {
    ["url", host] -> Ok(host)
    _ -> Error(Nil)
  }
}

fn not_found(_req) {
  not_found.render()
  |> html_response(404, _)
}

fn html_response(status, content) {
  let body =
    layout.render(template: content)
    |> bit_builder.from_string()

  response.new(status)
  |> response.prepend_header("Content-Type", "text/html")
  |> response.set_body(body)
}
