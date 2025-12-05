import day
import days/day5

const input = "3-5
10-14
16-20
12-18

1
5
8
11
17
32"

pub fn part_one_test() {
  assert day5.part_one(input) == day.IntResult(3)
}

pub fn part_two_test() {
  assert day5.part_two(input) == day.IntResult(14)
}
