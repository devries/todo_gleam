import envoy
import ewe
import gleam/erlang/process
import sqlight
import todo_gleam/database
import todo_gleam/logger
import todo_gleam/router
import todo_gleam/web.{Context}
import wisp
import wisp/wisp_ewe

pub fn main() {
  wisp.configure_logger()

  // Uncomment below for debug logging
  // wisp.set_logger_level(wisp.DebugLevel)

  let filename = case envoy.get("DBFILE") {
    Ok(f) -> f
    Error(Nil) -> "todo.db"
  }

  logger.log_info("Starting")

  // Set up the web server process
  let secret_key_base = wisp.random_string(64)
  let listener_name = process.new_name("ewe_listener")
  let connection_factory_name = process.new_name("ewe_connection_factory")

  use conn <- sqlight.with_connection("file:" <> filename)
  let _ = database.create_database(conn)

  let ctx = Context(static_directory: static_directory(), conn: conn)
  let handler = router.handle_request(_, ctx)

  let assert Ok(_) =
    handler
    |> wisp_ewe.handler(secret_key_base)
    |> ewe.new(listener_name:, connection_factory_name:, handler: _)
    |> ewe.bind(to: "::")
    |> ewe.listening(on: 8080)
    |> ewe.start

  logger.log_info("Listening on port 8080")
  process.sleep_forever()
}

// Static directory locator for wisp.
pub fn static_directory() -> String {
  let assert Ok(priv_directory) = wisp.priv_directory("todo_gleam")
  priv_directory <> "/static"
}
