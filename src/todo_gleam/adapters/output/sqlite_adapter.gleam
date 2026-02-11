// SQLite output adapter implementing the ItemReader and ItemWriter ports.
// This is the only module that depends on sqlight directly.

import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/result
import sqlight
import todo_gleam/domain/item.{type Item, CompletedItem, IncompleteItem}
import todo_gleam/domain/ports.{
  type ItemReader, type ItemWriter, ItemReader, ItemWriter,
}

// Create the todo item database table if it does not exist
pub fn create_database(conn: sqlight.Connection) -> Result(Nil, String) {
  let statement =
    "create table if not exists items(id integer primary key autoincrement, value TEXT, done INTEGER default 0)"

  sqlight.exec(statement, conn)
  |> result.map_error(fn(e) { "SQL Error: " <> e.message })
}

// Build an ItemReader port backed by SQLite
pub fn new_reader(conn: sqlight.Connection) -> ItemReader {
  ItemReader(get_all: fn() { get_todos(conn) }, get_one: fn(tid) {
    get_one_todo(conn, tid)
  })
}

// Build an ItemWriter port backed by SQLite
pub fn new_writer(conn: sqlight.Connection) -> ItemWriter {
  ItemWriter(
    add: fn(text) { add_todo(conn, text) },
    mark_done: fn(tid) { mark_todo_done(conn, tid) },
    mark_not_done: fn(tid) { mark_todo_not_done(conn, tid) },
    delete: fn(tid) { delete_todo(conn, tid) },
  )
}

// Get all the todos
fn get_todos(conn: sqlight.Connection) -> Result(List(Item), String) {
  let td_decoder = {
    use id <- decode.field(0, decode.int)
    use text <- decode.field(1, decode.string)
    use done <- decode.field(2, sqlight.decode_bool())
    decode.success(item_from_row(id, text, done))
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
fn get_one_todo(conn: sqlight.Connection, tid: Int) -> Result(Item, String) {
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
    [#(text, done)] -> Ok(item_from_row(tid, text, done))
    _ ->
      Error(
        "unexpected result: "
        <> int.to_string(list.length(rows))
        <> " rows returned",
      )
  }
}

// Add a new todo returning the new id
fn add_todo(conn: sqlight.Connection, text: String) -> Result(Int, String) {
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
fn mark_todo_done(conn: sqlight.Connection, tid: Int) -> Result(Nil, String) {
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
fn mark_todo_not_done(conn: sqlight.Connection, tid: Int) -> Result(Nil, String) {
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
fn delete_todo(conn: sqlight.Connection, tid: Int) -> Result(Nil, String) {
  sqlight.query(
    "delete from items where id=?",
    on: conn,
    with: [sqlight.int(tid)],
    expecting: decode.dynamic,
  )
  |> result.map_error(fn(e) { "SQL Error: " <> e.message })
  |> result.replace(Nil)
}

// Convert a database row to the domain Item type
fn item_from_row(id: Int, text: String, done: Bool) -> Item {
  case done {
    True -> CompletedItem(id:, text:)
    False -> IncompleteItem(id:, text:)
  }
}
