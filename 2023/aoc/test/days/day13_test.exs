defmodule AocTest.Day13Test do
  use ExUnit.Case

  alias Days.Day13

  test "part_one/1 works as expected" do
    assert Day13.part_one("""
           #.##..##.
           ..#.##.#.
           ##......#
           ##......#
           ..#.##.#.
           ..##..##.
           #.#.##.#.

           #...##..#
           #....#..#
           ..##..###
           #####.##.
           #####.##.
           ..##..###
           #....#..#
           """) == 405
  end

  test "part_two/1 works as expected" do
    assert Day13.part_two("""
           #.##..##.
           ..#.##.#.
           ##......#
           ##......#
           ..#.##.#.
           ..##..##.
           #.#.##.#.

           #...##..#
           #....#..#
           ..##..###
           #####.##.
           #####.##.
           ..##..###
           #....#..#
           """) == 400
  end
end
