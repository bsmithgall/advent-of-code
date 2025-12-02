import gleam/int

// https://github.com/gleam-lang/stdlib/blob/v0.67.0/src/gleam/int.gleam#L449
pub fn digits(x: Int, base: Int) -> Result(List(Int), Nil) {
  case base < 2 {
    True -> Error(Nil)
    False -> Ok(digits_loop(x, base, []))
  }
}

fn digits_loop(x: Int, base: Int, acc: List(Int)) -> List(Int) {
  case int.absolute_value(x) < base {
    True -> [x, ..acc]
    False -> digits_loop(x / base, base, [x % base, ..acc])
  }
}

pub fn all_equal(l: List(a)) -> Bool {
  case l {
    [] -> True
    [head, ..tail] -> all_equal_loop(tail, head)
  }
}

fn all_equal_loop(l: List(a), expected: a) -> Bool {
  case l {
    [] -> True
    [head, ..tail] ->
      case head == expected {
        True -> all_equal_loop(tail, expected)
        False -> False
      }
  }
}
