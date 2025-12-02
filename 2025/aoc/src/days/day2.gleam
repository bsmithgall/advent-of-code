import day
import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import util

pub const day = day.Day(part_one: part_one, part_two: part_two)

pub fn part_one(input: String) -> day.DayResult {
  parse(input)
  |> list.fold(0, fn(acc, x) {
    let #(start, end) = x
    count_loop(start, end, acc)
  })
  |> day.IntResult()
}

fn count_loop(x: Int, end: Int, acc: Int) -> Int {
  let digits = util.digits(x, 10) |> result.unwrap(list.new())
  let len = list.length(digits)

  let to_add = case match(digits, list.length(digits) / 2), len % 2 == 0 {
    _, False -> 0
    True, _ -> x
    False, _ -> 0
  }

  case x == end {
    True -> acc + to_add
    False -> count_loop(x + 1, end, acc + to_add)
  }
}

pub fn part_two(input: String) -> day.DayResult {
  parse(input)
  |> list.fold(0, fn(acc, x) {
    let #(start, end) = x
    count_many_loop(start, end, acc)
  })
  |> day.IntResult()
}

fn count_many_loop(x: Int, end: Int, acc: Int) -> Int {
  let to_add = case match_many(x) {
    True -> x
    False -> 0
  }

  case x == end {
    True -> acc + to_add
    False -> count_many_loop(x + 1, end, acc + to_add)
  }
}

fn match_many(x) -> Bool {
  let digits = util.digits(x, 10) |> result.unwrap(list.new())

  list.range(1, list.length(digits) / 2)
  |> list.any(fn(len) { match(digits, len) })
}

fn match(digits: List(Int), size: Int) -> Bool {
  use <- bool.guard(list.length(digits) == 1, False)
  use <- bool.guard(list.length(digits) % size != 0, False)
  list.sized_chunk(digits, size) |> util.all_equal()
}

fn parse(input: String) -> List(#(Int, Int)) {
  input
  |> string.split(",")
  |> list.map(fn(x) { string.split_once(x, "-") |> result.unwrap(#("", "")) })
  |> list.map(fn(x) {
    case x {
      #(l, r) -> #(
        result.unwrap(int.parse(l), 0),
        result.unwrap(int.parse(r), 0),
      )
    }
  })
}
