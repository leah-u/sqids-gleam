import gleeunit/should
import sqids_gleam

pub fn multibyte_character_test() {
  sqids_gleam.new(
    sqids_gleam.Options(..sqids_gleam.default_options(), alphabet: "ë1092"),
  )
  |> should.be_error
  |> should.equal(sqids_gleam.AlphabetMultibyteCharacters)
}

pub fn repeating_characters_test() {
  sqids_gleam.new(
    sqids_gleam.Options(..sqids_gleam.default_options(), alphabet: "aabcdefg"),
  )
  |> should.be_error
  |> should.equal(sqids_gleam.AlphabetRepeatingCharacters)
}

pub fn too_short_alphabet_test() {
  sqids_gleam.new(
    sqids_gleam.Options(..sqids_gleam.default_options(), alphabet: "ab"),
  )
  |> should.be_error
  |> should.equal(sqids_gleam.AlphabetLength)
}
