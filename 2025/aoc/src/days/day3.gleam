import day
import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/string
import util

pub const day = day.Day(part_one: part_one, part_two: part_two)

pub fn part_one(input: String) -> day.DayResult {
  parse(input)
  |> list.map(fn(x) { max_jolt(x, 2) |> util.undigits(10) |> result.unwrap(0) })
  |> int.sum()
  |> day.IntResult
}

pub fn part_two(input: String) -> day.DayResult {
  parse(input)
  |> list.map(fn(x) { max_jolt(x, 12) |> util.undigits(10) |> result.unwrap(0) })
  |> int.sum()
  |> day.IntResult
}

fn parse(input: String) -> List(List(Int)) {
  input
  |> string.split("\n")
  |> list.map(fn(x) {
    int.parse(x)
    |> result.unwrap(0)
    |> util.digits(10)
    |> result.unwrap(list.new())
  })
}

fn max_jolt(battery: List(Int), digits: Int) -> List(Int) {
  case digits {
    1 -> {
      let assert Ok(max) = battery |> list.max(int.compare)
      [max]
    }
    _ -> {
      let assert Ok(#(first_largest_value, first_largest_index)) =
        battery
        |> list.take(list.length(battery) - digits + 1)
        |> max_with_index(int.compare)

      list.append(
        [first_largest_value],
        max_jolt(list.drop(battery, first_largest_index + 1), digits - 1),
      )
    }
  }
}

fn max_with_index(
  list: List(a),
  compare: fn(a, a) -> order.Order,
) -> Result(#(a, Int), Nil) {
  case list {
    [] -> Error(Nil)
    [head, ..tail] -> {
      tail
      |> list.index_fold(#(head, 0), fn(acc, el, idx) {
        let #(cur_max, _) = acc
        case compare(el, cur_max) {
          order.Gt -> #(el, idx + 1)
          _ -> acc
        }
      })
      |> Ok
    }
  }
}
