import day
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub const day = day.Day(part_one: part_one, part_two: part_two)

pub fn part_one(input: String) -> day.DayResult {
  input
  |> string.split("\n")
  |> list.map(fn(x: String) { x |> int.parse() |> result.unwrap(0) })
  |> list.reduce(fn(acc: Int, x: Int) { acc + x })
  |> result.unwrap(0)
  |> day.IntResult()
}

pub fn part_two(input: String) -> day.DayResult {
  input
  |> string.split("\n")
  |> list.map(fn(x: String) { x |> int.parse() |> result.unwrap(0) })
  |> list.reduce(fn(acc: Int, x: Int) { acc * x })
  |> result.unwrap(0)
  |> day.IntResult()
}
