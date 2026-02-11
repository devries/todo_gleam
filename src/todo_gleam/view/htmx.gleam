import lustre/attribute.{attribute}

pub fn post(value: String) {
  attribute("hx-post", value)
}

pub fn get(value: String) {
  attribute("hx-get", value)
}

pub fn put(value: String) {
  attribute("hx-put", value)
}

pub fn delete(value: String) {
  attribute("hx-delete", value)
}

pub fn target(value: String) {
  attribute("hx-target", value)
}

pub fn swap(value: String) {
  attribute("hx-swap", value)
}
