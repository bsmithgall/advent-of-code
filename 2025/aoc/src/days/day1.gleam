import day
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

pub const day = day.Day(part_one: part_one, part_two: part_two)

pub fn part_one(input: String) -> day.DayResult {
  input
  |> string.split("\n")
  |> list.fold(#(0, 50), fn(acc: #(Int, Int), x: String) {
    let #(ct, pos) = acc
    let new_pos = case x {
      "L" <> i -> pos - { int.parse(i) |> result.unwrap(0) }
      "R" <> i -> pos + { int.parse(i) |> result.unwrap(0) }
      _ -> panic
    }

    case new_pos {
      new_pos if new_pos % 100 == 0 -> #(ct + 1, 0)
      new_pos if new_pos > 99 -> #(ct, rem_100(new_pos))
      new_pos if new_pos < 0 -> #(ct, rem_100(new_pos))
      _ -> #(ct, new_pos)
    }
  })
  |> pair.first
  |> day.IntResult()
}

pub fn part_two(input: String) -> day.DayResult {
  input
  |> string.split("\n")
  |> list.filter(fn(line) { line != "" })
  |> list.fold(#(0, 50), fn(acc: #(Int, Int), x: String) {
    let #(ct, pos) = acc

    let amt = case x {
      "L" <> i -> int.parse(i) |> result.unwrap(0) |> int.multiply(-1)
      "R" <> i -> int.parse(i) |> result.unwrap(0)
      _ -> panic
    }

    let clicks = case pos, amt {
      0, _ -> int.absolute_value(amt) / 100

      _, amt if amt > 0 -> {
        case amt >= { 100 - pos } {
          True -> 1 + { amt - { 100 - pos } } / 100
          False -> 0
        }
      }

      _, amt if amt < 0 -> {
        let abs_amt = int.absolute_value(amt)
        case abs_amt >= pos {
          True -> 1 + { abs_amt - pos } / 100
          False -> 0
        }
      }

      _, _ -> 0
    }

    #(ct + clicks, rem_100(pos + amt))
  })
  |> pair.first
  |> day.IntResult()
}

fn rem_100(x: Int) -> Int {
  x |> int.modulo(100) |> result.unwrap(0)
}
