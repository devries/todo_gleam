import gleam/int
import gleam/json
import lustre/attribute
import lustre/element
import lustre/element/html
import todo_gleam/domain/item.{type Item, CompletedItem, IncompleteItem}
import todo_gleam/htmx
import todo_gleam/style

// Render a todo item as a html li node.
pub fn fragment(item: Item) -> element.Element(Nil) {
  case item {
    CompletedItem(id:, text:) -> {
      html.li([style.item()], [
        html.button(
          [
            style.item_button(),
            attribute.aria_label("delete"),
            htmx.target("closest li"),
            htmx.swap("outerHTML"),
            htmx.delete("/delete/" <> int.to_string(id)),
          ],
          [style.delete_icon()],
        ),
        html.button(
          [
            style.item_button(),
            attribute.aria_label("undo"),
            htmx.target("closest li"),
            htmx.swap("outerHTML"),
            htmx.put("/undo/" <> int.to_string(id)),
          ],
          [style.undo_icon()],
        ),
        html.del([], [html.text(text)]),
      ])
    }
    IncompleteItem(id:, text:) -> {
      html.li([style.item()], [
        html.button(
          [
            style.item_button(),
            attribute.aria_label("do"),
            htmx.target("closest li"),
            htmx.swap("outerHTML"),
            htmx.put("/do/" <> int.to_string(id)),
          ],
          [style.check_icon()],
        ),
        html.button([style.hidden_item_button(), attribute.aria_hidden(True)], [
          style.undo_icon(),
        ]),
        html.text(text),
      ])
    }
  }
}

// Render a todo item as a JSON value
pub fn json_fragment(i: Item) -> json.Json {
  json.object([
    #("id", json.int(item.id(i))),
    #("text", json.string(item.text(i))),
    #("done", json.bool(item.is_completed(i))),
  ])
}
