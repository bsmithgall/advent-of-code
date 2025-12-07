import day
import days/day6

const input = "123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +  "

pub fn part_one_test() {
  assert day6.part_one(input) == day.IntResult(4_277_556)
}

pub fn part_two_test() {
  assert day6.part_two(input) == day.IntResult(3_263_827)
}
