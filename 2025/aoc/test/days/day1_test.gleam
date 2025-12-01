import day
import days/day1

const input = "L68
L30
R48
L5
R60
L55
L1
L99
R14
L82"

pub fn part_one_test() {
  assert day1.part_one(input) == day.IntResult(3)
}

pub fn part_two_test() {
  assert day1.part_two(input) == day.IntResult(6)
}
