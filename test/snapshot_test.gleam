import birdie
import gleam/json
import lustre/element
import todo_gleam/domain/item.{CompletedItem, IncompleteItem}
import todo_gleam/view/index
import todo_gleam/view/todo_item

pub fn html_head_test() {
  index.head()
  |> element.to_readable_string
  |> birdie.snap(title: "HTML head snapshot")
}

pub fn html_empty_body_test() {
  index.body([])
  |> element.to_readable_string
  |> birdie.snap(title: "HTML body structure snapshot")
}

pub fn html_todo_item_test() {
  let item = IncompleteItem(1, "sample")
  todo_item.fragment(item)
  |> element.to_readable_string
  |> birdie.snap(title: "HTML todo item snapshot")
}

pub fn html_todo_done_item_test() {
  let item = CompletedItem(1, "sample")

  todo_item.fragment(item)
  |> element.to_readable_string
  |> birdie.snap(title: "HTML done todo item snapsnot")
}

pub fn json_todo_item_test() {
  let item = IncompleteItem(1, "sample")
  todo_item.json_fragment(item)
  |> json.to_string
  |> birdie.snap(title: "JSON todo item snapshot")
}

pub fn json_todo_done_item_test() {
  let item = CompletedItem(1, "sample")

  todo_item.json_fragment(item)
  |> json.to_string
  |> birdie.snap(title: "JSON done todo item snapsnot")
}
