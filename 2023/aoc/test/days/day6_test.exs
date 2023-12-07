defmodule AocTest.Day6Test do
  use ExUnit.Case

  alias Days.Day6

  test "part_one/1 works as expected" do
    assert Day6.part_one("""
           Time:      7  15   30
           Distance:  9  40  200
           """) == 288
  end

  test "part_two/1 works as expected" do
    assert Day6.part_two("""
           Time:      7  15   30
           Distance:  9  40  200
           """) == 71503
  end
end
