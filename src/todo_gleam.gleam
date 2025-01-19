import gleam/erlang/process
import mist
import sqlight
import todo_gleam/database
import todo_gleam/logger
import todo_gleam/router
import todo_gleam/web.{Context}
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()
  // Uncomment below for debug logging
  // wisp.set_logger_level(wisp.DebugLevel)

  logger.log_info("Starting")

  // Set up the web server process
  let secret_key_base = wisp.random_string(64)

  use conn <- sqlight.with_connection("file:todo.db")
  let _ = database.create_database(conn)

  let ctx = Context(static_directory: static_directory(), conn: conn)
  let handler = router.handle_request(_, ctx)

  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.bind("::")
    |> mist.port(8080)
    |> mist.start_http

  logger.log_info("Listening on port 8080")
  process.sleep_forever()
}

// Static directory locator for wisp.
pub fn static_directory() -> String {
  let assert Ok(priv_directory) = wisp.priv_directory("todo_gleam")
  priv_directory <> "/static"
}
