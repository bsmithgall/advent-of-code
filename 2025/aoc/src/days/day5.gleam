import day
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub const day = day.Day(part_one: part_one, part_two: part_two)

pub fn part_one(input: String) -> day.DayResult {
  let #(ranges, ids) = parse(input)
  ids
  |> list.count(fn(id) {
    ranges
    |> list.any(fn(range) { range.start <= id && id <= range.end })
  })
  |> day.IntResult()
}

pub fn part_two(input: String) -> day.DayResult {
  let #(ranges, _) = parse(input)

  ranges
  |> list.fold(0, fn(acc, x) { acc + { x.end - x.start } + 1 })
  |> day.IntResult()
}

fn parse(input: String) -> #(List(Range), List(Int)) {
  let assert Ok(#(ranges, ids)) =
    input |> string.trim() |> string.split_once("\n\n")

  let ranges =
    ranges
    |> string.split("\n")
    |> list.map(fn(x) {
      case
        x
        |> string.split("-")
        |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
      {
        [start, end] -> Range(start: start, end: end)
        _ -> panic
      }
    })
    |> merge()

  let ids =
    ids
    |> string.split("\n")
    |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })

  #(ranges, ids)
}

type Range {
  Range(start: Int, end: Int)
}

fn merge(ranges: List(Range)) -> List(Range) {
  ranges
  |> list.sort(by: fn(a, b) { int.compare(a.start, b.start) })
  |> list.fold([], fn(acc: List(Range), x) {
    case acc {
      [] -> [x]
      [head, ..tail] -> {
        case x.start <= head.end + 1 {
          True -> [
            Range(int.min(x.start, head.start), int.max(x.end, head.end)),
            ..tail
          ]
          False -> [x, head, ..tail]
        }
      }
    }
  })
  |> list.reverse()
}
