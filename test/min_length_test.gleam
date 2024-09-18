import gleeunit/should
import sqids_gleam

pub fn invalid_min_length_test() {
  let min_length_limit = 255

  sqids_gleam.new(
    sqids_gleam.Options(..sqids_gleam.default_options(), min_length: -1),
  )
  |> should.be_error
  |> should.equal(sqids_gleam.InvalidMinLength)

  sqids_gleam.new(
    sqids_gleam.Options(
      ..sqids_gleam.default_options(),
      min_length: min_length_limit + 1,
    ),
  )
  |> should.be_error
  |> should.equal(sqids_gleam.InvalidMinLength)
}
