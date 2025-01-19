import gleam/http.{Delete, Get}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import nakai
import todo_gleam/database
import todo_gleam/logger
import todo_gleam/web.{type Context}
import wisp.{type Request, type Response}

// Router has 5 endpoints:
// / -> get entire page
// /delete/id -> delete item id
// /do/id -> do item id
// /undo/id -> undo item id
// /add -> add a new item
pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req, ctx)

  case wisp.path_segments(req) {
    [] -> main_page_handler(req, ctx)
    ["delete", id] -> delete_handler(req, ctx, id)
    ["do", id] -> do_handler(req, ctx, id)
    ["undo", id] -> undo_handler(req, ctx, id)
    ["add"] -> add_handler(req, ctx)
    _ -> wisp.not_found()
  }
}

// Send back the index page with all the current todos
fn main_page_handler(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Get)

  case database.get_todos(ctx.conn) {
    Error(message) -> {
      wisp.internal_server_error()
      |> wisp.set_header("content-type", "text/plain; charset=utf-8")
      |> wisp.string_body("Internal Server Error: " <> message)
    }
    Ok(items) -> {
      let page = nakai.to_string_tree(web.index(items))

      wisp.ok()
      |> wisp.html_body(page)
    }
  }
}

// Add a new todo item to the database and the UI
fn add_handler(req: Request, ctx: Context) -> Response {
  use form <- wisp.require_form(req)

  use #(_, item_text) <- emessage_to_isa({
    list.find(form.values, fn(tup) { tup.0 == "newTodo" })
    |> result.replace_error("unable to find a todo item")
  })

  let trimmed_text = string.trim(item_text)

  case trimmed_text == "" {
    True -> {
      wisp.bad_request()
      |> wisp.set_header("content-type", "text/plain; charset=utf=8")
      |> wisp.string_body("Empty todo items are not accepted")
    }
    False -> {
      use new_id <- emessage_to_isa(database.add_todo(ctx.conn, trimmed_text))

      let rendered_item =
        nakai.to_inline_string_tree(
          web.todo_item(database.Todo(new_id, trimmed_text, False)),
        )

      wisp.ok()
      |> wisp.html_body(rendered_item)
    }
  }
}

// Delete a todo item from the database and the UI
fn delete_handler(req: Request, ctx: Context, id: String) -> Response {
  use <- wisp.require_method(req, Delete)

  case int.parse(id) {
    Error(Nil) -> {
      wisp.bad_request()
      |> wisp.set_header("content-type", "text/plain; charset=utf-8")
      |> wisp.string_body("Unable to parse " <> id <> " as integer")
    }
    Ok(tid) -> {
      use _ <- emessage_to_isa(database.delete_todo(ctx.conn, tid))

      wisp.ok()
      |> wisp.string_body("")
    }
  }
}

// Mark a todo as done
fn do_handler(req: Request, ctx: Context, id: String) -> Response {
  use <- wisp.require_method(req, Get)

  case int.parse(id) {
    Error(Nil) -> {
      wisp.bad_request()
      |> wisp.set_header("content-type", "text/plain; charset=utf-8")
      |> wisp.string_body("Unable to parse " <> id <> " as integer")
    }
    Ok(tid) -> {
      use _ <- emessage_to_isa(database.mark_todo_done(ctx.conn, tid))

      use item <- emessage_to_isa(database.get_one_todo(ctx.conn, tid))

      let rendered_item = nakai.to_inline_string_tree(web.todo_item(item))

      wisp.ok()
      |> wisp.html_body(rendered_item)
    }
  }
}

// Mark a todo as not done
fn undo_handler(req: Request, ctx: Context, id: String) -> Response {
  use <- wisp.require_method(req, Get)

  case int.parse(id) {
    Error(Nil) -> {
      wisp.bad_request()
      |> wisp.set_header("content-type", "text/plain; charset=utf-8")
      |> wisp.string_body("Unable to parse " <> id <> " as integer")
    }
    Ok(tid) -> {
      use _ <- emessage_to_isa(database.mark_todo_not_done(ctx.conn, tid))

      use item <- emessage_to_isa(database.get_one_todo(ctx.conn, tid))

      let rendered_item = nakai.to_inline_string_tree(web.todo_item(item))

      wisp.ok()
      |> wisp.html_body(rendered_item)
    }
  }
}

fn internal_server_error(message: String) -> Response {
  logger.log_warning("Error: " <> message)
  wisp.internal_server_error()
  |> wisp.set_header("content-type", "text/plain; charset=utf-8")
  |> wisp.string_body("Internal Server Error: " <> message)
}

fn emessage_to_isa(
  result: Result(a, String),
  apply fun: fn(a) -> Response,
) -> Response {
  case result {
    Error(message) -> internal_server_error(message)
    Ok(v) -> fun(v)
  }
}
