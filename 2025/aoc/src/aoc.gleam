import argv
import day
import days/day0
import days/day1
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
