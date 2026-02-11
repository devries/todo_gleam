// Input adapter for the JSON API.
// Handles JSON endpoints: get one item, get all items, add item, complete item.

import gleam/dynamic/decode
import gleam/http.{Get, Post, Put}
import gleam/int
import gleam/json
import gleam/string
import todo_gleam/domain/ports.{type TodoService}
import todo_gleam/logger
import todo_gleam/view/todo_item
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

// Add a new todo item via JSON body with a "text" field
pub fn add_handler(req: Request, service: TodoService) -> Response {
  use <- wisp.require_method(req, Post)
  use json_body <- wisp.require_json(req)

  let text_decoder = {
    use text <- decode.field("text", decode.string)
    decode.success(text)
  }

  case decode.run(json_body, text_decoder) {
    Error(_) -> {
      wisp.bad_request("invalid JSON")
      |> wisp.json_body({
        json.object([
          #("error", json.string("Expected JSON object with \"text\" field")),
        ])
        |> json.to_string
      })
    }
    Ok(text) -> {
      let trimmed_text = string.trim(text)

      case trimmed_text == "" {
        True -> {
          wisp.bad_request("empty text")
          |> wisp.json_body({
            json.object([
              #("error", json.string("Empty todo items are not accepted")),
            ])
            |> json.to_string
          })
        }
        False -> {
          use new_item <- json_emessage_to_isa(service.add(trimmed_text))

          wisp.response(201)
          |> wisp.json_body({
            todo_item.json_fragment(new_item)
            |> json.to_string
          })
        }
      }
    }
  }
}

// Mark a todo item as completed and return it as JSON
pub fn complete_handler(
  req: Request,
  service: TodoService,
  id: String,
) -> Response {
  use <- wisp.require_method(req, Put)

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
      use completed_item <- json_emessage_to_isa(service.complete(tid))

      wisp.ok()
      |> wisp.json_body({
        todo_item.json_fragment(completed_item)
        |> json.to_string
      })
    }
  }
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
