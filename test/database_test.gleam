import gleam/list
import gleeunit
import gleeunit/should
import sqlight
import todo_gleam/database

pub fn main() {
  gleeunit.main()
}

pub fn write_read_test() {
  use conn <- sqlight.with_connection("file::memory:")

  database.create_database(conn)
  |> should.equal(Ok(Nil))

  let assert Ok(id1) = database.add_todo(conn, "item 1")
  let assert Ok(id2) = database.add_todo(conn, "item 2")

  let assert Ok(todos) = database.get_todos(conn)

  list.length(todos) |> should.equal(2)

  database.mark_todo_done(conn, id2)
  |> should.be_ok

  database.get_one_todo(conn, id1)
  |> should.equal(Ok(database.Todo(id1, "item 1", False)))

  database.get_one_todo(conn, id2)
  |> should.equal(Ok(database.Todo(id2, "item 2", True)))
}
