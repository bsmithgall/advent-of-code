defmodule AocTest.Day3Test do
  use ExUnit.Case

  alias Days.Day3

  test "part_one/1 works as expected" do
    assert Day3.part_one("""
           467..114..
           ...*......
           ..35..633.
           ......#...
           617*......
           .....+.58.
           ..592.....
           ......755.
           ...$.*....
           .664.598..
           """) == 4361
  end

  test "part_two/1 works as expected" do
    assert Day3.part_two("""
           467..114..
           ...*......
           ..35..633.
           ......#...
           617*......
           .....+.58.
           ..592.....
           ......755.
           ...$.*....
           .664.598..
           """) == 467_835
  end
end
