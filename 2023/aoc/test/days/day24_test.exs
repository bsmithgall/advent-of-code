defmodule AocTest.Day24Test do
  use ExUnit.Case

  alias Days.Day24

  test "part_one/1 works as expected" do
    assert Day24.part_one(
             """
             19, 13, 30 @ -2,  1, -2
             18, 19, 22 @ -1, -1, -2
             20, 25, 34 @ -2, -2, -4
             12, 31, 28 @ -1, -2, -1
             20, 19, 15 @  1, -5, -3
             """,
             7,
             27
           ) == 2
  end

  test "part_two/1 works as expected" do
    assert Day24.part_two("""
             19, 13, 30 @ -2,  1, -2
             18, 19, 22 @ -1, -1, -2
             20, 25, 34 @ -2, -2, -4
             12, 31, 28 @ -1, -2, -1
             20, 19, 15 @  1, -5, -3
           """) == 47
  end
end
