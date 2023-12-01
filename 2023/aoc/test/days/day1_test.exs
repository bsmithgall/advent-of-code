defmodule AocTest.Day1Test do
  use ExUnit.Case

  alias Days.Day1

  test "part_one/1 works as expected" do
    assert Day1.part_one("""
           1abc2
           pqr3stu8vwx
           a1b2c3d4e5f
           treb7uchet
           """) == 142
  end

  test "part_two/1 works as expected" do
    assert Day1.part_two("""
           two1nine
           eightwothree
           abcone2threexyz
           xtwone3four
           4nineeightseven2
           zoneight234
           7pqrstsixteen
           """) == 281
  end
end
