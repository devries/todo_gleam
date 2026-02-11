// TodoService implementation that wires the input port to the output ports.
// This is the application layer connecting domain logic to infrastructure.

import gleam/result
import todo_gleam/domain/item.{IncompleteItem}
import todo_gleam/domain/ports.{
  type ItemReader, type ItemWriter, type TodoService, TodoService,
}

// Build a TodoService from an ItemReader and ItemWriter
pub fn new(reader: ItemReader, writer: ItemWriter) -> TodoService {
  TodoService(
    get_all: reader.get_all,
    get_one: reader.get_one,
    add: add(writer, reader, _),
    complete: complete(writer, reader, _),
    uncomplete: uncomplete(writer, reader, _),
    delete: writer.delete,
  )
}

// Add a new item and return it
fn add(
  writer: ItemWriter,
  _reader: ItemReader,
  text: String,
) -> Result(item.Item, String) {
  use new_id <- result.try(writer.add(text))
  Ok(IncompleteItem(id: new_id, text: text))
}

// Mark an item as completed and return the updated item
fn complete(
  writer: ItemWriter,
  reader: ItemReader,
  tid: Int,
) -> Result(item.Item, String) {
  use _ <- result.try(writer.mark_done(tid))
  reader.get_one(tid)
}

// Mark an item as incomplete and return the updated item
fn uncomplete(
  writer: ItemWriter,
  reader: ItemReader,
  tid: Int,
) -> Result(item.Item, String) {
  use _ <- result.try(writer.mark_not_done(tid))
  reader.get_one(tid)
}
