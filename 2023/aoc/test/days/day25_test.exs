defmodule AocTest.Day25Test do
  use ExUnit.Case

  alias Days.Day25

  test "part_one/1 works as expected" do
    assert Day25.part_one("""
           jqt: rhn xhk nvd
           rsh: frs pzl lsr
           xhk: hfx
           cmg: qnr nvd lhk bvb
           rhn: xhk bvb hfx
           bvb: xhk hfx
           pzl: lsr hfx nvd
           qnr: nvd
           ntq: jqt hfx bvb xhk
           nvd: lhk
           lsr: lhk
           rzs: qnr cmg lsr rsh
           frs: qnr lhk lsr
           """) == 54
  end
end
