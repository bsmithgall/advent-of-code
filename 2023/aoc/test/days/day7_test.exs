defmodule AocTest.Day7Test do
  use ExUnit.Case

  alias Days.Day7

  test "part_one/1 works as expected" do
    assert Day7.part_one("""
           32T3K 765
           T55J5 684
           KK677 28
           KTJJT 220
           QQQJA 483
           """) == 6440
  end

  test "part_two/1 works as expected" do
    assert Day7.part_two("""
           32T3K 765
           T55J5 684
           KK677 28
           KTJJT 220
           QQQJA 483
           """) == 5905
  end
end
