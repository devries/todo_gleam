// The central domain type representing a todo item.
// Completion status is encoded in the variant rather than a boolean field.

pub type Item {
  CompletedItem(id: Int, text: String)
  IncompleteItem(id: Int, text: String)
}

// Check if an item is completed
pub fn is_completed(item: Item) -> Bool {
  case item {
    CompletedItem(_, _) -> True
    IncompleteItem(_, _) -> False
  }
}

// Get the id of an item regardless of variant
pub fn id(item: Item) -> Int {
  case item {
    CompletedItem(id:, text: _) -> id
    IncompleteItem(id:, text: _) -> id
  }
}

// Get the text of an item regardless of variant
pub fn text(item: Item) -> String {
  case item {
    CompletedItem(id: _, text:) -> text
    IncompleteItem(id: _, text:) -> text
  }
}

// Mark an item as completed
pub fn complete(item: Item) -> Item {
  CompletedItem(id: id(item), text: text(item))
}

// Mark an item as incomplete
pub fn uncomplete(item: Item) -> Item {
  IncompleteItem(id: id(item), text: text(item))
}
