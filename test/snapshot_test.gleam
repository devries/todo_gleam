import birdie
import gleam/json
import nakai
import todo_gleam/database.{Todo}
import todo_gleam/index
import todo_gleam/todo_item

pub fn html_head_test() {
  index.head()
  |> nakai.to_inline_string
  |> birdie.snap(title: "HTML head snapshot")
}

pub fn html_empty_body_test() {
  index.body([])
  |> nakai.to_inline_string
  |> birdie.snap(title: "HTML body structure snapshot")
}

pub fn html_todo_item_test() {
  let item = Todo(1, "sample", False)
  todo_item.fragment(item)
  |> nakai.to_inline_string
  |> birdie.snap(title: "HTML todo item snapshot")
}

pub fn html_todo_done_item_test() {
  let item = Todo(1, "sample", True)

  todo_item.fragment(item)
  |> nakai.to_inline_string
  |> birdie.snap(title: "HTML done todo item snapsnot")
}

pub fn json_todo_item_test() {
  let item = Todo(1, "sample", False)
  todo_item.json_fragment(item)
  |> json.to_string
  |> birdie.snap(title: "JSON todo item snapshot")
}

pub fn json_todo_done_item_test() {
  let item = Todo(1, "sample", True)

  todo_item.json_fragment(item)
  |> json.to_string
  |> birdie.snap(title: "JSON done todo item snapsnot")
}
