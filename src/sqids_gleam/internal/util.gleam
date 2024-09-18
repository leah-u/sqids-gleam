import gleam/set.{type Set}

pub fn set_filter_map(set: Set(a), with fun: fn(a) -> Result(b, c)) -> Set(b) {
  set.fold(over: set, from: set.new(), with: fn(acc, elem) {
    case fun(elem) {
      Ok(new_elem) -> set.insert(acc, new_elem)
      Error(_) -> acc
    }
  })
}
