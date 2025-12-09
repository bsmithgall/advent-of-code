import day
import days/day9

const input = "7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3"

pub fn part_one_test() {
  assert day9.part_one(input) == day.IntResult(50)
}

pub fn part_two_test() {
  assert day9.part_two(input) == day.IntResult(24)
}
