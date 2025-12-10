import argv
import day
import days/day0
import days/day1
import days/day10
import days/day2
import days/day3
import days/day4
import days/day5
import days/day6
import days/day7
import days/day8
import days/day9
import gleam/float
import gleam/io
import gleam/time/duration
import simplifile

pub fn main() -> Nil {
  let #(#(one_result, one_timing), #(two_result, two_timing)) = case
    argv.load().arguments
  {
    [] -> panic as "no day passed!"
    ["0"] -> day.exec(day0.day, input("0"))
    ["1"] -> day.exec(day1.day, input("1"))
    ["2"] -> day.exec(day2.day, input("2"))
    ["3"] -> day.exec(day3.day, input("3"))
    ["4"] -> day.exec(day4.day, input("4"))
    ["5"] -> day.exec(day5.day, input("5"))
    ["6"] -> day.exec(day6.day, input("6"))
    ["7"] -> day.exec(day7.day, input("7"))
    ["8"] -> day.exec(day8.day, input("8"))
    ["9"] -> day.exec(day9.day, input("9"))
    ["10"] -> day.exec(day10.day, input("10"))
    _ -> panic as "no day found!"
  }

  io.println(
    "Part 1 Result "
    <> one_result |> day.as_str()
    <> ", Took "
    <> one_timing
    |> duration.to_seconds()
    |> float.to_precision(4)
    |> float.to_string()
    <> "s",
  )
  io.println(
    "Part 2 Result "
    <> two_result |> day.as_str()
    <> ", Took "
    <> two_timing
    |> duration.to_seconds()
    |> float.to_precision(4)
    |> float.to_string()
    <> "s",
  )
}

fn input(day: String) -> String {
  let assert Ok(contents) =
    simplifile.read(from: "./src/inputs/day_" <> day <> ".txt")

  contents
}
