defmodule AocTest.Day14Test do
  use ExUnit.Case

  alias Days.Day14

  test "part_one/1 works as expected" do
    assert Day14.part_one("""
           O....#....
           O.OO#....#
           .....##...
           OO.#O....O
           .O.....O#.
           O.#..O.#.#
           ..O..#O..O
           .......O..
           #....###..
           #OO..#....
           """) == 136
  end

  test "part_two/1 works as expected" do
    assert Day14.part_two("""
           O....#....
           O.OO#....#
           .....##...
           OO.#O....O
           .O.....O#.
           O.#..O.#.#
           ..O..#O..O
           .......O..
           #....###..
           #OO..#....
           """) == 64
  end
end
