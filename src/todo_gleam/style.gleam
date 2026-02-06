import lustre/attribute
import lustre/element
import lustre/element/svg

pub fn titlebar() -> attribute.Attribute(Nil) {
  attribute.class("bg-underwater-blue w-full mb-6")
}

pub fn title() -> attribute.Attribute(Nil) {
  attribute.class(
    "m-auto max-w-3xl py-6 text-4xl text-faff-pink font-serif font-bold text-center",
  )
}

pub fn input_field() -> attribute.Attribute(Nil) {
  attribute.class(
    "grow bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block p-2.5",
  )
}

pub fn button() -> attribute.Attribute(Nil) {
  attribute.class(
    "text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 mx-2",
  )
}

pub fn content_div() -> attribute.Attribute(Nil) {
  attribute.class("m-auto max-w-3xl px-3 float-none")
}

pub fn item() -> attribute.Attribute(Nil) {
  attribute.class("my-2 flex flex-row items-center-safe")
}

pub fn item_button() -> attribute.Attribute(Nil) {
  attribute.class("pr-4 cursor-pointer text-blue-700")
}

pub fn hidden_item_button() -> attribute.Attribute(Nil) {
  attribute.class("pr-4 invisible")
}

pub fn undo_icon() -> element.Element(Nil) {
  // arrow-uturn-left mini icon from https://heroicons.com/

  svg.svg(
    [
      attribute.attribute("viewbox", "0 0 20 20"),
      attribute.attribute("fill", "currentColor"),
      attribute.class("size-5"),
    ],
    [
      svg.path([
        attribute.attribute("fill-rule", "evenodd"),
        attribute.attribute("clip-rule", "evenodd"),
        attribute.attribute(
          "d",
          "M7.793 2.232a.75.75 0 0 1-.025 1.06L3.622 7.25h10.003a5.375 5.375 0 0 1 0 10.75H10.75a.75.75 0 0 1 0-1.5h2.875a3.875 3.875 0 0 0 0-7.75H3.622l4.146 3.957a.75.75 0 0 1-1.036 1.085l-5.5-5.25a.75.75 0 0 1 0-1.085l5.5-5.25a.75.75 0 0 1 1.06.025Z",
        ),
      ]),
    ],
  )
}

pub fn check_icon() -> element.Element(Nil) {
  // check mini icon from https://heroicons.com/

  svg.svg(
    [
      attribute.attribute("viewbox", "0 0 20 20"),
      attribute.attribute("fill", "currentColor"),
      attribute.class("size-5"),
    ],
    [
      svg.path([
        attribute.attribute("fill-rule", "evenodd"),
        attribute.attribute("clip-rule", "evenodd"),
        attribute.attribute(
          "d",
          "M16.704 4.153a.75.75 0 0 1 .143 1.052l-8 10.5a.75.75 0 0 1-1.127.075l-4.5-4.5a.75.75 0 0 1 1.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 0 1 1.05-.143Z",
        ),
      ]),
    ],
  )
}

pub fn delete_icon() -> element.Element(Nil) {
  // x-mark mini icon from https://heroicons.com/

  svg.svg(
    [
      attribute.attribute("viewbox", "0 0 20 20"),
      attribute.attribute("fill", "currentColor"),
      attribute.class("size-5"),
    ],
    [
      svg.path([
        attribute.attribute("fill-rule", "evenodd"),
        attribute.attribute("clip-rule", "evenodd"),
        attribute.attribute(
          "d",
          "M6.28 5.22a.75.75 0 0 0-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 1 0 1.06 1.06L10 11.06l3.72 3.72a.75.75 0 1 0 1.06-1.06L11.06 10l3.72-3.72a.75.75 0 0 0-1.06-1.06L10 8.94 6.28 5.22Z",
        ),
      ]),
    ],
  )
}

pub fn paperclip_icon() -> element.Element(Nil) {
  // paper-clip mini icon from https://heroicons.com/

  svg.svg(
    [
      attribute.attribute("viewbox", "0 0 20 20"),
      attribute.attribute("fill", "currentColor"),
      attribute.class("size-5"),
    ],
    [
      svg.path([
        attribute.attribute("fill-rule", "evenodd"),
        attribute.attribute("clip-rule", "evenodd"),
        attribute.attribute(
          "d",
          "M15.621 4.379a3 3 0 0 0-4.242 0l-7 7a2 2 0 0 0 2.828 2.829l6-6a1 1 0 0 0-1.414-1.414l-6 6a.5.5 0 0 1-.707-.707l7-7a1.5 1.5 0 1 1 2.122 2.121l-7 7a3 3 0 0 1-4.242-4.242l7-7a1 1 0 0 0-1.414-1.414l-7 7a5 5 0 0 0 7.072 7.072l7-7a4.5 4.5 0 0 0-6.364-6.364l-7 7a1 1 0 0 0 1.414 1.414l7-7a2.5 2.5 0 0 1 3.536 3.536l-7 7a.5.5 0 0 1-.707 0 .5.5 0 0 1 0-.707l7-7a1 1 0 0 0 0-1.414Z",
        ),
      ]),
    ],
  )
}

pub fn download_icon() -> element.Element(Nil) {
  // arrow-down-tray mini icon from https://heroicons.com/

  svg.svg(
    [
      attribute.attribute("viewbox", "0 0 20 20"),
      attribute.attribute("fill", "currentColor"),
      attribute.class("size-5"),
    ],
    [
      svg.path([
        attribute.attribute("fill-rule", "evenodd"),
        attribute.attribute("clip-rule", "evenodd"),
        attribute.attribute(
          "d",
          "M10 3a.75.75 0 0 1 .75.75v6.638l1.96-2.158a.75.75 0 1 1 1.08 1.04l-3.25 3.5a.75.75 0 0 1-1.08 0l-3.25-3.5a.75.75 0 1 1 1.08-1.04l1.96 2.158V3.75A.75.75 0 0 1 10 3ZM3.75 13a.75.75 0 0 0 0 1.5h12.5a.75.75 0 0 0 0-1.5H3.75Z",
        ),
      ]),
    ],
  )
}
