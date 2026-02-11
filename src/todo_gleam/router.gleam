// Router dispatches requests to the appropriate input adapter.
// HTML/HTMX UI routes go to html_adapter, JSON API routes go to json_adapter.

import todo_gleam/adapters/input/html_adapter
import todo_gleam/adapters/input/json_adapter
import todo_gleam/web.{type Context}
import wisp.{type Request, type Response}

// Router has 9 endpoints across two adapters:
// HTML adapter:
//   / -> get entire page
//   /add -> add a new item
//   /delete/id -> delete item id
//   /do/id -> mark item id done
//   /undo/id -> mark item id not done
// JSON adapter:
//   /api/get/id -> get item id in JSON
//   /api/get -> get all items in JSON
//   /api/add -> add a new item via JSON
//   /api/do/id -> mark item id done via JSON
pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req, ctx)

  case wisp.path_segments(req) {
    [] -> html_adapter.main_page_handler(req, ctx.service)
    ["add"] -> html_adapter.add_handler(req, ctx.service)
    ["delete", id] -> html_adapter.delete_handler(req, ctx.service, id)
    ["do", id] -> html_adapter.do_handler(req, ctx.service, id)
    ["undo", id] -> html_adapter.undo_handler(req, ctx.service, id)
    ["api", "get", id] -> json_adapter.get_handler(req, ctx.service, id)
    ["api", "get"] -> json_adapter.getall_handler(req, ctx.service)
    ["api", "add"] -> json_adapter.add_handler(req, ctx.service)
    ["api", "do", id] -> json_adapter.complete_handler(req, ctx.service, id)
    _ -> wisp.not_found()
  }
}
