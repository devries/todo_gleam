import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/result
import sqlight

// The database operations either return an Ok(a) or an Error(String)
// where the string is an error message.

// Create the todo item database if it does not exist
pub fn create_database(conn: sqlight.Connection) -> Result(Nil, String) {
  let statement =
    "create table if not exists items(id integer primary key autoincrement, value TEXT, done INTEGER default 0)"

  sqlight.exec(statement, conn)
  |> result.map_error(fn(e) { "SQL Error: " <> e.message })
}

pub type Todo {
  Todo(id: Int, text: String, done: Bool)
}

// Get all the todos
pub fn get_todos(conn: sqlight.Connection) -> Result(List(Todo), String) {
  let td_decoder = {
    use id <- decode.field(0, decode.int)
    use text <- decode.field(1, decode.string)
    use done <- decode.field(2, sqlight.decode_bool())
    decode.success(Todo(id:, text:, done:))
  }

  sqlight.query(
    "select id, value, done from items",
    on: conn,
    with: [],
    expecting: td_decoder,
  )
  |> result.map_error(fn(e) { "SQL Error: " <> e.message })
}

// Get one todo by todo id
pub fn get_one_todo(conn: sqlight.Connection, tid: Int) -> Result(Todo, String) {
  let td_decoder = {
    use text <- decode.field(0, decode.string)
    use done <- decode.field(1, sqlight.decode_bool())
    decode.success(#(text, done))
  }

  use rows <- result.try({
    sqlight.query(
      "select value, done from items where id=?",
      on: conn,
      with: [sqlight.int(tid)],
      expecting: td_decoder,
    )
    |> result.map_error(fn(e) { "SQL Error: " <> e.message })
  })

  case rows {
    [#(text, done)] -> Ok(Todo(tid, text, done))
    _ ->
      Error(
        "unexpected result: "
        <> int.to_string(list.length(rows))
        <> " rows returned",
      )
  }
}

// Add a new todo returning the new id
pub fn add_todo(conn: sqlight.Connection, text: String) -> Result(Int, String) {
  use rows <- result.try({
    sqlight.query(
      "insert into items (value) VALUES (?) RETURNING id",
      on: conn,
      with: [sqlight.text(text)],
      expecting: {
        use id <- decode.field(0, decode.int)
        decode.success(id)
      },
    )
    |> result.map_error(fn(e) { "SQL Error: " <> e.message })
  })

  case rows {
    [id] -> Ok(id)
    _ ->
      Error(
        "unexpected result: "
        <> int.to_string(list.length(rows))
        <> " rows returned",
      )
  }
}

// Mark a todo as done by todo id.
pub fn mark_todo_done(conn: sqlight.Connection, tid: Int) -> Result(Nil, String) {
  sqlight.query(
    "update items set done=1 where id=?",
    on: conn,
    with: [sqlight.int(tid)],
    expecting: decode.dynamic,
  )
  |> result.map_error(fn(e) { "SQL Error: " <> e.message })
  |> result.replace(Nil)
}

// Mark todo as not done by todo id.
pub fn mark_todo_not_done(
  conn: sqlight.Connection,
  tid: Int,
) -> Result(Nil, String) {
  sqlight.query(
    "update items set done=0 where id=?",
    on: conn,
    with: [sqlight.int(tid)],
    expecting: decode.dynamic,
  )
  |> result.map_error(fn(e) { "SQL Error: " <> e.message })
  |> result.replace(Nil)
}

// Delete a todo by id.
pub fn delete_todo(conn: sqlight.Connection, tid: Int) -> Result(Nil, String) {
  sqlight.query(
    "delete from items where id=?",
    on: conn,
    with: [sqlight.int(tid)],
    expecting: decode.dynamic,
  )
  |> result.map_error(fn(e) { "SQL Error: " <> e.message })
  |> result.replace(Nil)
}
