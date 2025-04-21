import gleam/list
import nakai/attr
import nakai/html
import todo_gleam/database
import todo_gleam/htmx
import todo_gleam/todo_item

// Render the index page along with the list of todo items.
pub fn page(items: List(database.Todo)) -> html.Node {
  html.Html([], [head(), body(items)])
}

pub fn head() -> html.Node {
  html.Head([
    // Boilerplate
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
  ])
}

pub fn body(items: List(database.Todo)) -> html.Node {
  html.Body([attr.class("m-auto max-w-3xl px-3 float-none")], [
    html.h1_text(
      [attr.class("py-6 text-4xl font-serif font-bold")],
      "Who do that todo that you do?",
    ),
    todo_form(),
    html.p([attr.class("hidden text-red-500"), attr.id("send-error")], [
      html.Text("Error communicating with server"),
    ]),
    html.div([], [
      html.ul(
        [attr.class("p-0"), attr.id("list")],
        list.map(items, todo_item.fragment),
      ),
    ]),
    html.div([attr.class("p-6")], [
      html.img([
        attr.class("mx-auto"),
        attr.src("static/createdwith.jpeg"),
        attr.alt("Site created with HTMX"),
        attr.width("200"),
      ]),
    ]),
  ])
}

pub fn todo_form() -> html.Node {
  html.form(
    [
      attr.class("flex flex-row"),
      attr.id("addition"),
      htmx.post("/add"),
      htmx.target("#list"),
      htmx.swap("beforeend"),
    ],
    [
      html.input([
        attr.class(
          "grow bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500",
        ),
        attr.type_("text"),
        attr.name("newTodo"),
        attr.placeholder("Todo..."),
      ]),
      html.button(
        [
          attr.class(
            "text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 mx-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800",
          ),
          attr.type_("submit"),
        ],
        [html.Text("Add")],
      ),
    ],
  )
}
