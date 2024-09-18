import gleam/set
import gleeunit
import gleeunit/should
import sqids_gleam/internal/util

pub fn main() {
  gleeunit.main()
}

pub fn set_filter_map_test() {
  set.from_list([0, 1, 2, 3])
  |> util.set_filter_map(fn(n) {
    case n % 2 == 0 {
      True -> Ok(n * 2)
      False -> Error(Nil)
    }
  })
  |> should.equal(set.from_list([0, 4]))
}
