defmodule AocTest.Day16Test do
  use ExUnit.Case

  alias Days.Day16

  test "part_one/1 works as expected" do
    assert Day16.part_one("""
           .|...\\....
           |.-.\\.....
           .....|-...
           ........|.
           ..........
           .........\\
           ..../.\\\\..
           .-.-/..|..
           .|....-|.\\
           ..//.|....
           """) == 46
  end

  test "part_two/1 works as expected" do
    assert Day16.part_two("""
           .|...\\....
           |.-.\\.....
           .....|-...
           ........|.
           ..........
           .........\\
           ..../.\\\\..
           .-.-/..|..
           .|....-|.\\
           ..//.|....
           """) == 51
  end
end
