defmodule AocTest.Day9Test do
  use ExUnit.Case

  alias Days.Day9

  test "part_one/1 works as expected" do
    assert Day9.part_one("""
           0 3 6 9 12 15
           1 3 6 10 15 21
           10 13 16 21 30 45
           """) == 114
  end

  test "part_two/1 works as expected" do
    assert Day9.part_two("""
           0 3 6 9 12 15
           1 3 6 10 15 21
           10 13 16 21 30 45
           """) == 2
  end
end
