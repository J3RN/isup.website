import gleam/http.{Request}
import gleam/io
import gleam/option.{None, Some}
import gleam/string

pub fn log(req: Request(BitString)) -> Nil {
  io.println(string.concat([
    "Recieved ",
    method(req),
    " request to ",
    req.path,
    params(req),
  ]))
}

fn method(req: Request(BitString)) -> String {
  case req.method {
    http.Connect -> "CONNECT"
    http.Delete -> "DELETE"
    http.Get -> "GET"
    http.Head -> "HEAD"
    http.Options -> "OPTIONS"
    http.Other(_other) -> "OTHER"
    http.Patch -> "PATCH"
    http.Post -> "POST"
    http.Put -> "PUT"
    http.Trace -> "TRACE"
  }
}

fn params(req: Request(BitString)) -> String {
  case req.query {
    Some(query) -> query
    None -> ""
  }
}
