import gleam/bit_array
import gleam/bool
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import sqids_gleam/internal/blocklist
import sqids_gleam/internal/util

pub type SqidsError {
  InvalidMinLength
  AlphabetMultibyteCharacters
  AlphabetLength
  AlphabetRepeatingCharacters
}

pub type EncodeError {
  InvalidNumbers
  MaxAttempts
}

pub opaque type Sqids {
  Sqids(alphabet: BitArray, min_length: Int, blocklist: Set(String))
}

pub type Options {
  Options(alphabet: String, min_length: Int, blocklist: Set(String))
}

pub fn default_options() -> Options {
  Options(
    alphabet: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
    min_length: 0,
    blocklist: set.from_list(blocklist.default_blocklist),
  )
}

pub fn default() -> Sqids {
  let assert Ok(sqids) = new(default_options())
  sqids
}

pub fn new(options: Options) -> Result(Sqids, SqidsError) {
  use <- bool.guard(
    when: options.min_length < 0 || options.min_length > 255,
    return: Error(InvalidMinLength),
  )

  let alphabet = bit_array.from_string(options.alphabet)
  let alphabet_length = string.length(options.alphabet)

  use <- bool.guard(when: alphabet_length < 3, return: Error(AlphabetLength))

  use <- bool.guard(
    when: alphabet_length != alphabet |> bit_array.byte_size,
    return: Error(AlphabetMultibyteCharacters),
  )

  let unique_characters =
    options.alphabet
    |> string.split("")
    |> set.from_list
    |> set.size

  use <- bool.guard(
    when: alphabet_length != unique_characters,
    return: Error(AlphabetRepeatingCharacters),
  )

  let lowercase_alphabet = string.lowercase(options.alphabet)
  let filtered_blocklist =
    options.blocklist
    |> util.set_filter_map(fn(word) {
      let word = string.lowercase(word)
      case
        string.length(word) >= 3
        && string.split(word, "")
        |> list.all(string.contains(lowercase_alphabet, _))
      {
        True -> Ok(word)
        False -> Error(Nil)
      }
    })

  Ok(Sqids(
    alphabet: shuffle(alphabet),
    min_length: options.min_length,
    blocklist: filtered_blocklist,
  ))
}

pub fn encode(sqids: Sqids, numbers: List(Int)) -> Result(String, EncodeError) {
  case numbers {
    [] -> Ok("")
    _ ->
      case list.all(numbers, is_number_encodable) {
        True -> encode_numbers(sqids, numbers, 0)
        False -> Error(InvalidNumbers)
      }
  }
}

fn encode_numbers(
  sqids: Sqids,
  numbers: List(Int),
  increment: Int,
) -> Result(String, EncodeError) {
  use <- bool.guard(
    when: increment > bit_array.byte_size(sqids.alphabet),
    return: Error(MaxAttempts),
  )
  let alphabet_length = bit_array.byte_size(sqids.alphabet)
  let offset =
    list.index_fold(numbers, list.length(numbers), fn(a, v, i) {
      value_at(sqids.alphabet, v % alphabet_length) + i + a
    })
    % alphabet_length

  let offset = { offset + increment } % alphabet_length
  let alphabet = {
    let assert Ok(left) = bit_array.slice(sqids.alphabet, 0, offset)
    let assert Ok(right) =
      bit_array.slice(sqids.alphabet, offset, alphabet_length - offset)
    bit_array.concat([right, left])
  }
  let prefix = value_at(alphabet, 0)
  let alphabet =
    bit_array.to_string(alphabet)
    |> result.unwrap("")
    |> string.reverse
    |> bit_array.from_string

  let #(ret, alphabet) =
    list.index_fold(numbers, #(<<prefix>>, alphabet), fn(acc, number, i) {
      let #(ret, alphabet) = acc
      let assert Ok(alphabet_without_separator) =
        bit_array.slice(alphabet, 1, alphabet_length - 1)
      // let ret = bit_array.append(ret, to_id(number, alphabet_without_separator))
      let ret = <<ret:bits, to_id(number, alphabet_without_separator):bits>>
      case i < list.length(numbers) - 1 {
        True -> {
          let assert Ok(separator) = bit_array.slice(alphabet, 0, 1)
          let ret = <<ret:bits, separator:bits>>
          let alphabet = shuffle(alphabet)
          #(ret, alphabet)
        }
        False -> #(ret, alphabet)
      }
    })

  let assert Ok(id) = ret |> bit_array.to_string
  Ok(id)
}

fn to_id(num: Int, alphabet: BitArray) {
  do_to_id(<<>>, num, alphabet)
}

fn do_to_id(id: BitArray, result: Int, alphabet: BitArray) {
  case result {
    0 -> id
    _ -> {
      let index = result % bit_array.byte_size(alphabet)
      let id = <<value_at(alphabet, index), id:bits>>
      let result = result / bit_array.byte_size(alphabet)
      do_to_id(id, result, alphabet)
    }
  }
}

@internal
pub fn shuffle(alphabet: BitArray) -> BitArray {
  do_shuffle(0, bit_array.byte_size(alphabet) - 1, alphabet)
}

fn do_shuffle(i: Int, j: Int, alphabet: BitArray) -> BitArray {
  case j {
    0 -> alphabet
    _ -> {
      let r =
        { i * j + value_at(alphabet, i) + value_at(alphabet, j) }
        % bit_array.byte_size(alphabet)
      do_shuffle(i + 1, j - 1, swap(i, r, alphabet))
    }
  }
}

@external(javascript, "./sqids_gleam_ffi.mjs", "swap")
fn swap(x: Int, y: Int, chars: BitArray) -> BitArray {
  case x, y {
    l, r if l == r -> chars
    l, r if l > r -> swap(y, x, chars)
    l, r -> {
      let prefix_size = l
      let interfix_size = r - l - 1
      let assert <<
        prefix:bytes-size(prefix_size),
        left:bytes-size(1),
        interfix:bytes-size(interfix_size),
        right:bytes-size(1),
        suffix:bytes,
      >> = chars
      bit_array.concat([prefix, right, interfix, left, suffix])
    }
  }
}

fn value_at(alphabet: BitArray, position: Int) -> Int {
  let assert Ok(<<n>>) = bit_array.slice(from: alphabet, at: position, take: 1)
  n
}

@external(javascript, "./sqids_gleam_ffi.mjs", "is_number_encodable")
fn is_number_encodable(n: Int) -> Bool {
  n > 0
}
