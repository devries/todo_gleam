// Input adapter for the JSON API.
// Handles JSON endpoints: get one item, get all items.

import gleam/http.{Get}
import gleam/int
import gleam/json
import todo_gleam/domain/ports.{type TodoService}
import todo_gleam/logger
import todo_gleam/todo_item
import wisp.{type Request, type Response}

// Get a single todo item as JSON
pub fn get_handler(req: Request, service: TodoService, id: String) -> Response {
  use <- wisp.require_method(req, Get)

  case int.parse(id) {
    Error(Nil) -> {
      wisp.bad_request("unable to parse")
      |> wisp.json_body({
        json.object([
          #("error", json.string("Unable to parse " <> id <> " as integer")),
        ])
        |> json.to_string
      })
    }
    Ok(tid) -> {
      use item <- json_emessage_to_isa(service.get_one(tid))

      wisp.ok()
      |> wisp.json_body({
        todo_item.json_fragment(item)
        |> json.to_string
      })
    }
  }
}

// Get all todo items as JSON
pub fn getall_handler(req: Request, service: TodoService) -> Response {
  use <- wisp.require_method(req, Get)

  use items <- json_emessage_to_isa(service.get_all())

  wisp.ok()
  |> wisp.json_body({
    json.array(from: items, of: todo_item.json_fragment)
    |> json.to_string
  })
}

// Convert a Result error message into a JSON internal server error response
fn json_emessage_to_isa(
  result: Result(a, String),
  apply fun: fn(a) -> Response,
) -> Response {
  case result {
    Error(message) -> json_internal_server_error(message)
    Ok(v) -> fun(v)
  }
}

fn json_internal_server_error(message: String) -> Response {
  logger.log_warning("Error: " <> message)
  wisp.internal_server_error()
  |> wisp.json_body({
    json.object([#("error", json.string("Internal Server Error: " <> message))])
    |> json.to_string
  })
}
