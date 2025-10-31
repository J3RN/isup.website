// External
import wisp.{type Request, type Response}

// Application
import isup/web/router

pub fn handle(req: Request) -> Response {
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  router.route(req)
}
