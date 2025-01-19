import birl
import gleam/bytes_tree
import gleam/http
import gleam/http/request
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/string_tree
import nakai/attr
import nakai/html
import sqlight
import todo_gleam/database
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

  let now = birl.now()

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
    birl.to_iso8601(now),
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
    wisp.Text(sb) -> Ok(string_tree.byte_size(sb))
    wisp.Bytes(bb) -> Ok(bytes_tree.byte_size(bb))
    wisp.File(_) -> Error(Nil)
    wisp.Empty -> Ok(0)
  }
}

// Render a todo item as a html li node.
pub fn todo_item(item: database.Todo) -> html.Node {
  case item.done {
    True -> {
      html.li([], [
        html.span(
          [
            attr.Attr("hx-target", "closest li"),
            attr.Attr("hx-swap", "outerHTML"),
            attr.Attr("hx-delete", "/delete/" <> int.to_string(item.id)),
          ],
          [html.UnsafeInlineHtml("&times;")],
        ),
        html.span(
          [
            attr.Attr("hx-target", "closest li"),
            attr.Attr("hx-swap", "outerHTML"),
            attr.Attr("hx-get", "/undo/" <> int.to_string(item.id)),
          ],
          [html.Text("↺")],
        ),
        html.s_text([], item.text),
      ])
    }
    False -> {
      html.li([], [
        html.span(
          [
            attr.Attr("hx-target", "closest li"),
            attr.Attr("hx-swap", "outerHTML"),
            attr.Attr("hx-get", "/do/" <> int.to_string(item.id)),
          ],
          [html.UnsafeInlineHtml("&times;")],
        ),
        html.Text(item.text),
      ])
    }
  }
}

// Render the index page along with the list of todo items.
pub fn index(items: List(database.Todo)) -> html.Node {
  html.Body([], [
    html.Head([
      // Boilderplate
      html.meta([attr.http_equiv("X-UA-Compatible"), attr.content("IE=edge")]),
      html.meta([
        attr.name("viewport"),
        attr.content("width=device-width, initial-scale=1"),
      ]),
      html.title("Who do that todo that you do?"),
      html.link([attr.rel("stylesheet"), attr.href("static/main.css")]),
      html.link([attr.rel("icon"), attr.href("static/favicon.png")]),
      html.Element("script", [attr.src("static/htmx.min.js")], []),
      html.Element("script", [attr.src("static/local.js")], []),
    ]),
    html.h1_text([], "Who do that todo that you do?"),
    html.form(
      [
        attr.class("hform"),
        attr.id("addition"),
        attr.Attr("hx-post", "/add"),
        attr.Attr("hx-target", "#list"),
        attr.Attr("hx-swap", "beforeend"),
      ],
      [
        html.input([
          attr.type_("text"),
          attr.name("newTodo"),
          attr.placeholder("Todo..."),
        ]),
        html.button([attr.type_("submit")], [html.Text("Add")]),
      ],
    ),
    html.p([attr.class("hide"), attr.id("send-error")], [
      html.Text("Error communicating with server"),
    ]),
    html.div([], [html.ul([attr.id("list")], list.map(items, todo_item))]),
    html.div([attr.class("footer")], [
      html.img([
        attr.src("static/createdwith.jpeg"),
        attr.alt("Site created with HTMX"),
        attr.width("200"),
      ]),
    ]),
  ])
}
