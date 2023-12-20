defmodule AocTest.Day20Test do
  use ExUnit.Case

  alias Days.Day20

  test "part_one/1 works as expected" do
    assert Day20.part_one("""
           broadcaster -> a, b, c
           %a -> b
           %b -> c
           %c -> inv
           &inv -> a
           """) == 32_000_000

    assert Day20.part_one("""
           broadcaster -> a
           %a -> inv, con
           &inv -> b
           %b -> con
           &con -> output
           """) == 11_687_500
  end
end
