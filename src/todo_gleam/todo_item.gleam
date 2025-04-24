import gleam/int
import gleam/json
import lustre/attribute
import lustre/element
import lustre/element/html
import todo_gleam/database
import todo_gleam/htmx

// Render a todo item as a html li node.
pub fn fragment(item: database.Todo) -> element.Element(Nil) {
  case item.done {
    True -> {
      html.li([attribute.class("my-2")], [
        element.unsafe_raw_html(
          "",
          "span",
          [
            attribute.class("pr-4 cursor-pointer text-2xl text-blue-700"),
            attribute.role("button"),
            attribute.aria_label("delete"),
            htmx.target("closest li"),
            htmx.swap("outerHTML"),
            htmx.delete("/delete/" <> int.to_string(item.id)),
          ],
          "&times;",
        ),
        html.span(
          [
            attribute.class("pr-4 cursor-pointer text-xl text-blue-700"),
            attribute.role("button"),
            attribute.aria_label("undo"),
            htmx.target("closest li"),
            htmx.swap("outerHTML"),
            htmx.put("/undo/" <> int.to_string(item.id)),
          ],
          [html.text("↺")],
        ),
        html.del([], [html.text(item.text)]),
      ])
    }
    False -> {
      html.li([attribute.class("my-2")], [
        element.unsafe_raw_html(
          "",
          "span",
          [
            attribute.class("pr-4 cursor-pointer text-2xl text-blue-700"),
            attribute.role("button"),
            attribute.aria_label("do"),
            htmx.target("closest li"),
            htmx.swap("outerHTML"),
            htmx.put("/do/" <> int.to_string(item.id)),
          ],
          "&times;",
        ),
        html.span(
          [
            attribute.class("pr-4 invisible text-xl text-blue-700"),
            attribute.aria_hidden(True),
          ],
          [html.text("↺")],
        ),
        html.text(item.text),
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
