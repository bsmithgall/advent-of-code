import day
import days/day4

const input = "..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@."

pub fn part_one_test() {
  assert day4.part_one(input) == day.IntResult(13)
}

pub fn part_two_test() {
  assert day4.part_two(input) == day.IntResult(43)
}
