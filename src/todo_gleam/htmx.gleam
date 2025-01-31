import nakai/attr.{type Attr, Attr}

pub fn post(value: String) -> Attr {
  Attr(name: "hx-post", value: value)
}

pub fn get(value: String) -> Attr {
  Attr(name: "hx-get", value: value)
}

pub fn put(value: String) -> Attr {
  Attr(name: "hx-put", value: value)
}

pub fn delete(value: String) -> Attr {
  Attr(name: "hx-delete", value: value)
}

pub fn target(value: String) -> Attr {
  Attr(name: "hx-target", value: value)
}

pub fn swap(value: String) -> Attr {
  Attr(name: "hx-swap", value: value)
}
