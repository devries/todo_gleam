import birl
import gleam/string
import wisp

pub fn log_debug(message: String) {
  let now = birl.now()

  [birl.to_iso8601(now), " ", message]
  |> string.concat
  |> wisp.log_debug
}

pub fn log_info(message: String) {
  let now = birl.now()

  [birl.to_iso8601(now), " ", message]
  |> string.concat
  |> wisp.log_info
}

pub fn log_warning(message: String) {
  let now = birl.now()

  [birl.to_iso8601(now), " ", message]
  |> string.concat
  |> wisp.log_warning
}
