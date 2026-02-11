// Input adapter for the HTTP/HTMX HTML UI.
// Handles HTML endpoints: main page, add, delete, do, undo.

import gleam/http.{Delete, Get, Put}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/string_tree
import lustre/element
import todo_gleam/domain/ports.{type TodoService}
import todo_gleam/logger
import todo_gleam/view/index
import todo_gleam/view/todo_item
import wisp.{type Request, type Response}

// Send back the index page with all the current todos
pub fn main_page_handler(req: Request, service: TodoService) -> Response {
  use <- wisp.require_method(req, Get)

  case service.get_all() {
    Error(message) -> {
      wisp.internal_server_error()
      |> wisp.set_header("content-type", "text/plain; charset=utf-8")
      |> wisp.string_body("Internal Server Error: " <> message)
    }
    Ok(items) -> {
      let page = element.to_document_string_tree(index.page(items))

      wisp.ok()
      |> wisp.html_body(string_tree.to_string(page))
    }
  }
}

// Add a new todo item to the database and the UI
pub fn add_handler(req: Request, service: TodoService) -> Response {
  use form <- wisp.require_form(req)

  use #(_, item_text) <- emessage_to_isa({
    list.find(form.values, fn(tup) { tup.0 == "newTodo" })
    |> result.replace_error("unable to find a todo item")
  })

  let trimmed_text = string.trim(item_text)

  case trimmed_text == "" {
    True -> {
      wisp.bad_request("Empty todo item")
      |> wisp.set_header("content-type", "text/plain; charset=utf=8")
      |> wisp.string_body("Empty todo items are not accepted")
    }
    False -> {
      use new_item <- emessage_to_isa(service.add(trimmed_text))

      let rendered_item = element.to_string_tree(todo_item.fragment(new_item))

      wisp.ok()
      |> wisp.html_body(string_tree.to_string(rendered_item))
    }
  }
}

// Delete a todo item from the database and the UI
pub fn delete_handler(
  req: Request,
  service: TodoService,
  id: String,
) -> Response {
  use <- wisp.require_method(req, Delete)

  case int.parse(id) {
    Error(Nil) -> {
      wisp.bad_request("Unable to parse")
      |> wisp.set_header("content-type", "text/plain; charset=utf-8")
      |> wisp.string_body("Unable to parse " <> id <> " as integer")
    }
    Ok(tid) -> {
      use _ <- emessage_to_isa(service.delete(tid))

      wisp.ok()
      |> wisp.string_body("")
    }
  }
}

// Mark a todo as done
pub fn do_handler(req: Request, service: TodoService, id: String) -> Response {
  use <- wisp.require_method(req, Put)

  case int.parse(id) {
    Error(Nil) -> {
      wisp.bad_request("unable to parse")
      |> wisp.set_header("content-type", "text/plain; charset=utf-8")
      |> wisp.string_body("Unable to parse " <> id <> " as integer")
    }
    Ok(tid) -> {
      use completed_item <- emessage_to_isa(service.complete(tid))

      let rendered_item =
        element.to_string_tree(todo_item.fragment(completed_item))

      wisp.ok()
      |> wisp.html_body(string_tree.to_string(rendered_item))
    }
  }
}

// Mark a todo as not done
pub fn undo_handler(req: Request, service: TodoService, id: String) -> Response {
  use <- wisp.require_method(req, Put)

  case int.parse(id) {
    Error(Nil) -> {
      wisp.bad_request("unable to parse")
      |> wisp.set_header("content-type", "text/plain; charset=utf-8")
      |> wisp.string_body("Unable to parse " <> id <> " as integer")
    }
    Ok(tid) -> {
      use uncompleted_item <- emessage_to_isa(service.uncomplete(tid))

      let rendered_item =
        element.to_string_tree(todo_item.fragment(uncompleted_item))

      wisp.ok()
      |> wisp.html_body(string_tree.to_string(rendered_item))
    }
  }
}

// Convert a Result error message into an internal server error response
fn emessage_to_isa(
  result: Result(a, String),
  apply fun: fn(a) -> Response,
) -> Response {
  case result {
    Error(message) -> internal_server_error(message)
    Ok(v) -> fun(v)
  }
}

fn internal_server_error(message: String) -> Response {
  logger.log_warning("Error: " <> message)
  wisp.internal_server_error()
  |> wisp.set_header("content-type", "text/plain; charset=utf-8")
  |> wisp.string_body("Internal Server Error: " <> message)
}
