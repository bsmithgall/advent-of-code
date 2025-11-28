import gleam/float
import gleam/int
import gleam/time/duration
import gleam/time/timestamp

pub type DayResult {
  StringResult(String)
  IntResult(Int)
  FloatResult(Float)
}

pub fn as_str(self: DayResult) -> String {
  case self {
    StringResult(s) -> s
    IntResult(s) -> int.to_string(s)
    FloatResult(s) -> float.to_string(s)
  }
}

pub type Day {
  Day(part_one: fn(String) -> DayResult, part_two: fn(String) -> DayResult)
}

pub fn exec(
  self: Day,
  input: String,
) -> #(#(DayResult, duration.Duration), #(DayResult, duration.Duration)) {
  let one_start = timestamp.system_time()
  let one_result = self.part_one(input)
  let one_end = timestamp.system_time()

  let two_start = timestamp.system_time()
  let two_result = self.part_two(input)
  let two_end = timestamp.system_time()

  #(#(one_result, timestamp.difference(one_start, one_end)), #(
    two_result,
    timestamp.difference(two_start, two_end),
  ))
}
