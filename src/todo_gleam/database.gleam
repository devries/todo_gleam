import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/result
import sqlight

// The database operations either return an Ok(a) or an Error(String)
// where the string is an error message.

// Create the todo item database if it does not exist
pub fn create_database(conn: sqlight.Connection) -> Result(Nil, String) {
  let items_statement =
    "create table if not exists items(id integer primary key autoincrement, value TEXT, done INTEGER default 0)"

  use _ <- result.try(
    sqlight.exec(items_statement, conn)
    |> result.map_error(fn(e) { "SQL Error: " <> e.message }),
  )

  let attachments_statement =
    "create table if not exists attachments(id integer primary key autoincrement, item_id integer, filename TEXT, content BLOB, foreign key(item_id) references items(id) on delete cascade)"

  sqlight.exec(attachments_statement, conn)
  |> result.map_error(fn(e) { "SQL Error: " <> e.message })
}

pub type Todo {
  Todo(id: Int, text: String, done: Bool, attachment: Option(String))
}

pub type Attachment {
  Attachment(filename: String, content: BitArray)
}

// Get all the todos
pub fn get_todos(conn: sqlight.Connection) -> Result(List(Todo), String) {
  let td_decoder = {
    use id <- decode.field(0, decode.int)
    use text <- decode.field(1, decode.string)
    use done <- decode.field(2, sqlight.decode_bool())
    use attachment <- decode.field(3, decode.optional(decode.string))
    decode.success(Todo(id:, text:, done:, attachment:))
  }

  sqlight.query(
    "select items.id, items.value, items.done, attachments.filename from items left join attachments on items.id = attachments.item_id",
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
    use attachment <- decode.field(2, decode.optional(decode.string))
    decode.success(#(text, done, attachment))
  }

  use rows <- result.try({
    sqlight.query(
      "select items.value, items.done, attachments.filename from items left join attachments on items.id = attachments.item_id where items.id=?",
      on: conn,
      with: [sqlight.int(tid)],
      expecting: td_decoder,
    )
    |> result.map_error(fn(e) { "SQL Error: " <> e.message })
  })

  case rows {
    [#(text, done, attachment)] -> Ok(Todo(tid, text, done, attachment))
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

pub fn add_attachment(
  conn: sqlight.Connection,
  tid: Int,
  filename: String,
  content: BitArray,
) -> Result(Nil, String) {
  sqlight.query(
    "insert into attachments (item_id, filename, content) values (?, ?, ?)",
    on: conn,
    with: [sqlight.int(tid), sqlight.text(filename), sqlight.blob(content)],
    expecting: decode.dynamic,
  )
  |> result.map_error(fn(e) { "SQL Error: " <> e.message })
  |> result.replace(Nil)
}

pub fn get_attachment(
  conn: sqlight.Connection,
  tid: Int,
) -> Result(Attachment, String) {
  let decoder = {
    use filename <- decode.field(0, decode.string)
    use content <- decode.field(1, decode.bit_array)
    decode.success(Attachment(filename, content))
  }

  use rows <- result.try(
    sqlight.query(
      "select filename, content from attachments where item_id = ?",
      on: conn,
      with: [sqlight.int(tid)],
      expecting: decoder,
    )
    |> result.map_error(fn(e) { "SQL Error: " <> e.message }),
  )

  case rows {
    [attachment] -> Ok(attachment)
    _ -> Error("Attachment not found")
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
