import gleam/dynamic/decode
import gleam/json
import todo_gleam/database

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
        decode.success(Ok(database.Todo(id:, text:, done:)))
      },
      or: [
        {
          use message <- decode.field("error", decode.string)
          decode.success(Error(message))
        },
      ],
    )

  let assert Ok(v) = json.parse(from: good, using: decoder)
  assert v == Ok(database.Todo(12, "Have a bath?", True))

  let assert Ok(v) = json.parse(from: bad, using: decoder)

  assert v == Error("Internal Server Error: unexpected result: 0 rows returned")
}
