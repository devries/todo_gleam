import gleam/int
import gleam/json
import nakai/html
import todo_gleam/database
import todo_gleam/htmx

// Render a todo item as a html li node.
pub fn fragment(item: database.Todo) -> html.Node {
  case item.done {
    True -> {
      html.li([], [
        html.span(
          [
            htmx.target("closest li"),
            htmx.swap("outerHTML"),
            htmx.delete("/delete/" <> int.to_string(item.id)),
          ],
          [html.UnsafeInlineHtml("&times;")],
        ),
        html.span(
          [
            htmx.target("closest li"),
            htmx.swap("outerHTML"),
            htmx.put("/undo/" <> int.to_string(item.id)),
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
            htmx.target("closest li"),
            htmx.swap("outerHTML"),
            htmx.put("/do/" <> int.to_string(item.id)),
          ],
          [html.UnsafeInlineHtml("&times;")],
        ),
        html.Text(item.text),
      ])
    }
  }
}

pub fn json_fragment(item: database.Todo) -> json.Json {
  json.object([
    #("id", json.int(item.id)),
    #("text", json.string(item.text)),
    #("done", json.bool(item.done)),
  ])
}
