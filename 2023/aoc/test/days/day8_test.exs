defmodule AocTest.Day8Test do
  use ExUnit.Case

  alias Days.Day8

  test "part_one/1 works as expected" do
    assert Day8.part_one("""
           RL

           AAA = (BBB, CCC)
           BBB = (DDD, EEE)
           CCC = (ZZZ, GGG)
           DDD = (DDD, DDD)
           EEE = (EEE, EEE)
           GGG = (GGG, GGG)
           ZZZ = (ZZZ, ZZZ)
           """) == 2

    assert Day8.part_one("""
           LLR

           AAA = (BBB, BBB)
           BBB = (AAA, ZZZ)
           ZZZ = (ZZZ, ZZZ)
           """) == 6
  end

  test "part_two/1 works as expected" do
    assert Day8.part_two("""
           LR

           11A = (11B, XXX)
           11B = (XXX, 11Z)
           11Z = (11B, XXX)
           22A = (22B, XXX)
           22B = (22C, 22C)
           22C = (22Z, 22Z)
           22Z = (22B, 22B)
           XXX = (XXX, XXX)
           """) == 6
  end
end
