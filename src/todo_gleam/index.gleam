import gleam/list
import lustre/attribute
import lustre/element
import lustre/element/html
import todo_gleam/database
import todo_gleam/htmx
import todo_gleam/todo_item

// Render the index page along with the list of todo items.
pub fn page(items: List(database.Todo)) -> element.Element(a) {
  html.html([], [head(), body(items)])
}

pub fn head() -> element.Element(a) {
  html.head([], [
    // Boilerplate
    html.meta([
      attribute.http_equiv("X-UA-Compatible"),
      attribute.content("IE=edge"),
    ]),
    html.meta([
      attribute.name("viewport"),
      attribute.content("width=device-width, initial-scale=1"),
    ]),
    html.title([], "Who do that todo that you do?"),
    html.link([attribute.rel("stylesheet"), attribute.href("static/main.css")]),
    html.link([attribute.rel("icon"), attribute.href("static/favicon.png")]),
    html.script([attribute.src("static/htmx.min.js")], ""),
    html.script([attribute.src("static/local.js")], ""),
  ])
}

pub fn body(items: List(database.Todo)) -> element.Element(a) {
  html.body([attribute.class("m-auto max-w-3xl px-3 float-none")], [
    html.h1([attribute.class("py-6 text-4xl font-serif font-bold")], [
      html.text("Who do that todo that you do?"),
    ]),
    todo_form(),
    html.p(
      [attribute.class("hidden text-red-500"), attribute.id("send-error")],
      [html.text("Error communicating with server")],
    ),
    html.div([], [
      html.ul(
        [attribute.class("p-0"), attribute.id("list")],
        list.map(items, todo_item.fragment),
      ),
    ]),
    html.div([attribute.class("p-6")], [
      html.img([
        attribute.class("mx-auto"),
        attribute.src("static/createdwith.jpeg"),
        attribute.alt("Site created with HTMX"),
        attribute.attribute("width", "200"),
      ]),
    ]),
  ])
}

pub fn todo_form() -> element.Element(a) {
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
        attribute.class(
          "grow bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block p-2.5",
        ),
        attribute.type_("text"),
        attribute.name("newTodo"),
        attribute.placeholder("Todo..."),
      ]),
      html.button(
        [
          attribute.class(
            "text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 mx-2",
          ),
          attribute.type_("submit"),
        ],
        [html.text("Add")],
      ),
    ],
  )
}
