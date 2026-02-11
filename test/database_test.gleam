import gleam/list
import sqlight
import todo_gleam/adapters/output/sqlite_adapter
import todo_gleam/domain/item.{CompletedItem, IncompleteItem}
import todo_gleam/domain/service

pub fn write_read_test() {
  use conn <- sqlight.with_connection("file::memory:")

  assert sqlite_adapter.create_database(conn) == Ok(Nil)

  let reader = sqlite_adapter.new_reader(conn)
  let writer = sqlite_adapter.new_writer(conn)
  let svc = service.new(reader, writer)

  let assert Ok(item1) = svc.add("item 1")
  let assert Ok(item2) = svc.add("item 2")

  let assert Ok(todos) = svc.get_all()

  assert list.length(todos) == 2

  let assert Ok(_) = svc.complete(item.id(item2))

  assert svc.get_one(item.id(item1))
    == Ok(IncompleteItem(id: item.id(item1), text: "item 1"))

  assert svc.get_one(item.id(item2))
    == Ok(CompletedItem(id: item.id(item2), text: "item 2"))
}
