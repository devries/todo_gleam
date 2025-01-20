import gleam/int
import nakai/attr
import nakai/html
import todo_gleam/database

// Render a todo item as a html li node.
pub fn fragment(item: database.Todo) -> html.Node {
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
