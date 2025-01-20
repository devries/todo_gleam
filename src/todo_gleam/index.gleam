import gleam/list
import nakai/attr
import nakai/html
import todo_gleam/database
import todo_gleam/todo_item

// Render the index page along with the list of todo items.
pub fn page(items: List(database.Todo)) -> html.Node {
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
    html.div([], [
      html.ul([attr.id("list")], list.map(items, todo_item.fragment)),
    ]),
    html.div([attr.class("footer")], [
      html.img([
        attr.src("static/createdwith.jpeg"),
        attr.alt("Site created with HTMX"),
        attr.width("200"),
      ]),
    ]),
  ])
}
