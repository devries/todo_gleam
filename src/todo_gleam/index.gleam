import gleam/list
import lustre/attribute
import lustre/element
import lustre/element/html
import todo_gleam/database
import todo_gleam/htmx
import todo_gleam/style
import todo_gleam/todo_item

// Render the index page along with the list of todo items.
pub fn page(items: List(database.Todo)) -> element.Element(Nil) {
  html.html([attribute.lang("en")], [head(), body(items)])
}

pub fn head() -> element.Element(Nil) {
  html.head([], [
    // Boilerplate
    html.meta([attribute.charset("utf-8")]),
    html.meta([
      attribute.http_equiv("X-UA-Compatible"),
      attribute.content("IE=edge"),
    ]),
    html.meta([
      attribute.name("viewport"),
      attribute.content("width=device-width, initial-scale=1"),
    ]),
    html.title([], "Who do that todo that you do?"),
    html.link([
      attribute.rel("manifest"),
      attribute.href("static/manifest.json"),
    ]),
    html.link([attribute.rel("stylesheet"), attribute.href("static/main.css")]),
    html.link([attribute.rel("icon"), attribute.href("static/favicon.png")]),
    html.script([attribute.src("static/htmx.min.js")], ""),
    html.script([attribute.src("static/local.js")], ""),
  ])
}

pub fn body(items: List(database.Todo)) -> element.Element(Nil) {
  html.body([], [
    html.header([style.titlebar()], [
      html.h1([style.title()], [html.text("Who do that todo that you do?")]),
    ]),
    html.main([style.content_div()], [
      todo_form(),
      html.p(
        [
          attribute.class("hidden text-red-500"),
          attribute.id("send-error"),
          attribute.role("status"),
          attribute.aria_live("polite"),
        ],
        [html.text("Error communicating with server")],
      ),
      html.div([], [
        html.ul(
          [attribute.class("p-0"), attribute.id("list")],
          list.map(items, todo_item.fragment),
        ),
      ]),
    ]),
  ])
}

pub fn todo_form() -> element.Element(Nil) {
  html.form(
    [
      attribute.class("flex flex-row"),
      attribute.id("addition"),
      htmx.post("/add"),
      htmx.target("#list"),
      htmx.swap("beforeend"),
    ],
    [
      html.input([
        style.input_field(),
        attribute.type_("text"),
        attribute.name("newTodo"),
        attribute.aria_label("Todo entry box"),
        attribute.placeholder("Todo..."),
      ]),
      html.button([style.button(), attribute.type_("submit")], [
        html.text("Add"),
      ]),
    ],
  )
}
