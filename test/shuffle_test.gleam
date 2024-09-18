import gleam/bit_array
import gleeunit/should
import sqids_gleam

fn shuffle_tester(input: String, output: String) {
  sqids_gleam.shuffle(
    input
    |> bit_array.from_string,
  )
  |> bit_array.to_string
  |> should.be_ok
  |> should.equal(output)
}

pub fn shuffle_test() {
  shuffle_tester(
    sqids_gleam.default_options().alphabet,
    "fwjBhEY2uczNPDiloxmvISCrytaJO4d71T0W3qnMZbXVHg6eR8sAQ5KkpLUGF9",
  )

  shuffle_tester(
    "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
    "ec38UaynYXvoxSK7RV9uZ1D2HEPw6isrdzAmBNGT5OCJLk0jlFbtqWQ4hIpMgf",
  )

  shuffle_tester(
    "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
    "ec38UaynYXvoxSK7RV9uZ1D2HEPw6isrdzAmBNGT5OCJLk0jlFbtqWQ4hIpMgf",
  )
  shuffle_tester(
    "1023456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
    "xI3RUayk1MSolQK7e09zYmFpVXPwHiNrdfBJ6ZAT5uCWbntgcDsEqjv4hLG28O",
  )

  shuffle_tester(
    "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
    "ec38UaynYXvoxSK7RV9uZ1D2HEPw6isrdzAmBNGT5OCJLk0jlFbtqWQ4hIpMgf",
  )

  shuffle_tester(
    "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY",
    "x038UaykZMSolIK7RzcbYmFpgXEPHiNr1d2VfGAT5uJWQetjvDswqn94hLC6BO",
  )

  shuffle_tester("0123456789", "4086517392")

  shuffle_tester("12345", "24135")

  shuffle_tester("abcdefghijklmnopqrstuvwxyz", "lbfziqvscptmyxrekguohwjand")

  shuffle_tester("ABCDEFGHIJKLMNOPQRSTUVWXYZ", "ZXBNSIJQEDMCTKOHVWFYUPLRGA")
}
