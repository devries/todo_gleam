import gleam/bytes_tree
import gleam/http
import gleam/http/request
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/time/calendar
import gleam/time/timestamp
import sqlight
import wisp

pub type Context {
  Context(static_directory: String, conn: sqlight.Connection)
}

// The middleware hangs on to the context and set up logging and some defaults
// as well as logging. It also serves the static content.
pub fn middleware(
  req: wisp.Request,
  ctx: Context,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- detail_log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use <- wisp.serve_static(req, under: "/static", from: ctx.static_directory)
  handle_request(req)
}

// For logging I assume this exists behind a proxy so I can pull the IP address
// from the X-Forwarded-For header. I log at the info level the date, IP, response
// status code, request method, and path.
pub fn detail_log_request(
  req: wisp.Request,
  handler: fn() -> wisp.Response,
) -> wisp.Response {
  let response = handler()

  // let now = birl.now()
  let now = timestamp.system_time()

  let client_ip = {
    case list.key_find(req.headers, "x-forwarded-for") {
      Ok(ip) -> ip
      Error(_) -> "unknown_ip"
    }
  }

  let user_agent = request.get_header(req, "user-agent") |> result.unwrap("")
  let response_size = case get_body_size(response.body) {
    Ok(n) -> int.to_string(n)
    Error(Nil) -> "Unknown"
  }

  [
    timestamp.to_rfc3339(now, calendar.utc_offset),
    " ",
    client_ip,
    " - ",
    string.uppercase(http.method_to_string(req.method)),
    " ",
    req.path,
    " ",
    int.to_string(response.status),
    " ",
    response_size,
    " \"",
    user_agent,
    "\"",
  ]
  |> string.concat
  |> wisp.log_info
  response
}

// Get the size of the response if it is not a file
fn get_body_size(body: wisp.Body) -> Result(Int, Nil) {
  case body {
    wisp.Text(sb) -> Ok(string.byte_size(sb))
    wisp.Bytes(bb) -> Ok(bytes_tree.byte_size(bb))
    wisp.File(_, _, _) -> Error(Nil)
  }
}
