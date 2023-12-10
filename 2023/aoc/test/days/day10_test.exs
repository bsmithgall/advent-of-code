defmodule AocTest.Day10Test do
  use ExUnit.Case

  alias Days.Day10

  test "part_one/1 works as expected" do
    assert Day10.part_one("""
           ..F7.
           .FJ|.
           SJ.L7
           |F--J
           LJ...
           """) == 8
  end

  test "part_two/1 works as expected" do
    assert Day10.part_two("""
           ..........
           .S------7.
           .|F----7|.
           .||OOOO||.
           .||OOOO||.
           .|L-7F-J|.
           .|..||..|.
           .L--JL--J.
           ..........
           """) == 4

    assert Day10.part_two("""
           FF7FSF7F7F7F7F7F---7
           L|LJ||||||||||||F--J
           FL-7LJLJ||||||LJL-77
           F--JF--7||LJLJ7F7FJ-
           L---JF-JLJ.||-FJLJJ7
           |F|F-JF---7F7-L7L|7|
           |FFJF7L7F-JF7|JL---7
           7-L-JL7||F7|L7F-7F7|
           L.L7LFJ|||||FJL7||LJ
           L7JLJL-JLJLJL--JLJ.L
           """) == 10
  end
end
