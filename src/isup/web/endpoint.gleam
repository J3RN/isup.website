// External
import gleam/http/request.{Request}
import gleam/http/response.{Response}
// Stdlib
import gleam/bit_builder.{BitBuilder}
// Application
import isup/logger
import isup/web/router

pub fn handle(req: Request(BitString)) -> Response(BitBuilder) {
  logger.log(req)
  router.route(req)
}
