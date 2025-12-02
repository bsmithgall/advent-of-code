import day
import days/day2

const input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"

pub fn part_one_test() {
  assert day2.part_one(input) == day.IntResult(1_227_775_554)
}

pub fn part_two_test() {
  assert day2.part_two(input) == day.IntResult(4_174_379_265)
}
