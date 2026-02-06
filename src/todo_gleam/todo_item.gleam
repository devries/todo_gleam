import gleam/int
import gleam/json
import gleam/option.{None, Some}
import lustre/attribute
import lustre/element
import lustre/element/html
import todo_gleam/database
import todo_gleam/htmx
import todo_gleam/style

// Render a todo item as a html li node.
pub fn fragment(item: database.Todo) -> element.Element(Nil) {
  let attachment_link = case item.attachment {
    Some(filename) -> {
      html.a(
        [
          attribute.href("/download/" <> int.to_string(item.id)),
          attribute.class(
            "ml-4 text-blue-600 hover:underline flex items-center",
          ),
          attribute.download(filename),
        ],
        [
          html.span([attribute.class("mr-1")], [style.download_icon()]),
          html.text(filename),
        ],
      )
    }
    None -> element.none()
  }

  case item.done {
    True -> {
      html.li([style.item()], [
        html.button(
          [
            style.item_button(),
            attribute.aria_label("delete"),
            htmx.target("closest li"),
            htmx.swap("outerHTML"),
            htmx.delete("/delete/" <> int.to_string(item.id)),
          ],
          [style.delete_icon()],
        ),
        html.button(
          [
            style.item_button(),
            attribute.aria_label("undo"),
            htmx.target("closest li"),
            htmx.swap("outerHTML"),
            htmx.put("/undo/" <> int.to_string(item.id)),
          ],
          [style.undo_icon()],
        ),
        html.del([], [html.text(item.text)]),
        attachment_link,
      ])
    }
    False -> {
      html.li([style.item()], [
        html.button(
          [
            style.item_button(),
            attribute.aria_label("do"),
            htmx.target("closest li"),
            htmx.swap("outerHTML"),
            htmx.put("/do/" <> int.to_string(item.id)),
          ],
          [style.check_icon()],
        ),
        html.button([style.hidden_item_button(), attribute.aria_hidden(True)], [
          style.undo_icon(),
        ]),
        html.text(item.text),
        attachment_link,
      ])
    }
  }
}

pub fn json_fragment(item: database.Todo) -> json.Json {
  json.object([
    #("id", json.int(item.id)),
    #("text", json.string(item.text)),
    #("done", json.bool(item.done)),
    #("attachment", json.nullable(item.attachment, json.string)),
  ])
}
