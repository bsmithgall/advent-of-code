defmodule AocTest.Day22Test do
  use ExUnit.Case

  alias Days.Day22

  test "part_one/1 works as expected" do
    assert Day22.part_one("""
           1,0,1~1,2,1
           0,0,2~2,0,2
           0,2,3~2,2,3
           0,0,4~0,2,4
           2,0,5~2,2,5
           0,1,6~2,1,6
           1,1,8~1,1,9
           """) == 5
  end

  test "part_two/1 works as expected" do
    assert Day22.part_two("""
           1,0,1~1,2,1
           0,0,2~2,0,2
           0,2,3~2,2,3
           0,0,4~0,2,4
           2,0,5~2,2,5
           0,1,6~2,1,6
           1,1,8~1,1,9
           """) == 7
  end
end
