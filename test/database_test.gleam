import gleam/list
import sqlight
import todo_gleam/database

pub fn write_read_test() {
  use conn <- sqlight.with_connection("file::memory:")

  assert database.create_database(conn) == Ok(Nil)

  let assert Ok(id1) = database.add_todo(conn, "item 1")
  let assert Ok(id2) = database.add_todo(conn, "item 2")

  let assert Ok(todos) = database.get_todos(conn)

  assert list.length(todos) == 2

  let assert Ok(_) = database.mark_todo_done(conn, id2)

  assert database.get_one_todo(conn, id1)
    == Ok(database.Todo(id1, "item 1", False))

  assert database.get_one_todo(conn, id2)
    == Ok(database.Todo(id2, "item 2", True))
}
