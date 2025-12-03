import day
import days/day3

const input = "987654321111111
811111111111119
234234234234278
818181911112111"

pub fn part_one_test() {
  assert day3.part_one(input) == day.IntResult(357)
}

pub fn part_two_test() {
  assert day3.part_two(input) == day.IntResult(3_121_910_778_619)
}
