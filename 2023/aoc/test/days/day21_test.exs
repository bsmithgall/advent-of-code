defmodule AocTest.Day21Test do
  use ExUnit.Case

  alias Days.Day21

  test "part_one/1 works as expected" do
    assert Day21.part_one(
             """
             ...........
             .....###.#.
             .###.##..#.
             ..#.#...#..
             ....#.#....
             .##..S####.
             .##..#...#.
             .......##..
             .##.#.####.
             .##..##.##.
             ...........
             """,
             6
           ) == 16
  end
end
