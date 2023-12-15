defmodule AocTest.Day15Test do
  use ExUnit.Case

  alias Days.Day15

  test "part_one/1 works as expected" do
    assert Day15.part_one("""
           rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
           """) == 1320
  end

  test "part_two/1 works as expected" do
    assert Day15.part_two("""
           rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
           """) == 145
  end
end
