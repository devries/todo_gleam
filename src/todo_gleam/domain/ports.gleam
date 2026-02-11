// Port definitions for the hexagonal architecture.
// Ports are record types wrapping function signatures that define
// the boundaries between the domain and the outside world.

import todo_gleam/domain/item.{type Item}

// Output port for reading items from storage
pub type ItemReader {
  ItemReader(
    get_all: fn() -> Result(List(Item), String),
    get_one: fn(Int) -> Result(Item, String),
  )
}

// Output port for writing items to storage
pub type ItemWriter {
  ItemWriter(
    add: fn(String) -> Result(Int, String),
    mark_done: fn(Int) -> Result(Nil, String),
    mark_not_done: fn(Int) -> Result(Nil, String),
    delete: fn(Int) -> Result(Nil, String),
  )
}

// Input port defining the service interface that adapters call
pub type TodoService {
  TodoService(
    get_all: fn() -> Result(List(Item), String),
    get_one: fn(Int) -> Result(Item, String),
    add: fn(String) -> Result(Item, String),
    complete: fn(Int) -> Result(Item, String),
    uncomplete: fn(Int) -> Result(Item, String),
    delete: fn(Int) -> Result(Nil, String),
  )
}
