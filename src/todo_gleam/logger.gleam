import gleam/string
import gleam/time/calendar
import gleam/time/timestamp
import wisp

pub fn log_debug(message: String) {
  let now = timestamp.system_time()

  [timestamp.to_rfc3339(now, calendar.utc_offset), " ", message]
  |> string.concat
  |> wisp.log_debug
}

pub fn log_info(message: String) {
  let now = timestamp.system_time()

  [timestamp.to_rfc3339(now, calendar.utc_offset), " ", message]
  |> string.concat
  |> wisp.log_info
}

pub fn log_warning(message: String) {
  let now = timestamp.system_time()

  [timestamp.to_rfc3339(now, calendar.utc_offset), " ", message]
  |> string.concat
  |> wisp.log_warning
}
