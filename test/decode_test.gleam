import gleam/dynamic/decode
import gleam/json
import todo_gleam/domain/item.{CompletedItem, IncompleteItem}

pub fn decode_test() {
  let good = "{\"id\":12,\"text\":\"Have a bath?\",\"done\":true}"
  let bad =
    "{\"error\":\"Internal Server Error: unexpected result: 0 rows returned\"}"

  let decoder =
    decode.one_of(
      {
        use id <- decode.field("id", decode.int)
        use text <- decode.field("text", decode.string)
        use done <- decode.field("done", decode.bool)
        case done {
          True -> decode.success(Ok(CompletedItem(id:, text:)))
          False -> decode.success(Ok(IncompleteItem(id:, text:)))
        }
      },
      or: [
        {
          use message <- decode.field("error", decode.string)
          decode.success(Error(message))
        },
      ],
    )

  let assert Ok(v) = json.parse(from: good, using: decoder)
  assert v == Ok(CompletedItem(12, "Have a bath?"))

  let assert Ok(v) = json.parse(from: bad, using: decoder)

  assert v == Error("Internal Server Error: unexpected result: 0 rows returned")
}
