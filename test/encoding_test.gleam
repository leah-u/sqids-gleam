import gleeunit/should
import sqids_gleam

pub fn simple_test() {
  sqids_gleam.default()
  |> sqids_gleam.encode([1, 2, 3])
  |> should.be_ok
  |> should.equal("86Rf07")
}
