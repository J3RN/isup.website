// DO NOT EDIT: Code generated by matcha from moved.matcha

import gleam/string_builder.{StringBuilder}
import gleam/list

import gleam/option

pub fn render_builder(url url: String, new_location new_location: option.Option(String)) -> StringBuilder {
    let builder = string_builder.from_string("")
    let builder = string_builder.append(builder, "

")
    let builder = case option.is_some(new_location) {
        True -> {
                let builder = string_builder.append(builder, "
  <h1>")
    let builder = string_builder.append(builder, url)
    let builder = string_builder.append(builder, " has been moved to ")
    let builder = string_builder.append(builder, option.unwrap(new_location, ""))
    let builder = string_builder.append(builder, "</h1>
  <form method='post' action=\"/lookup\">
    <input type=\"hidden\" name=\"url\" value='")
    let builder = string_builder.append(builder, option.unwrap(new_location, ""))
    let builder = string_builder.append(builder, "' />
    <button>Try ")
    let builder = string_builder.append(builder, option.unwrap(new_location, ""))
    let builder = string_builder.append(builder, "</button>
  </form>
")

            builder
        }
        False -> {
                let builder = string_builder.append(builder, "
  <h1>")
    let builder = string_builder.append(builder, url)
    let builder = string_builder.append(builder, " has been moved</h1>
  <h2>However, the server did not specify <i>where</i></h2>
")

            builder
        }
}
    let builder = string_builder.append(builder, "
<p>Try another</p>
")

    builder
}

pub fn render(url url: String, new_location new_location: option.Option(String)) -> String {
    string_builder.to_string(render_builder(url: url, new_location: new_location))
}
