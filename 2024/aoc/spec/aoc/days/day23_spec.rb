require_relative "../../../lib/aoc/days/day23"

RSpec.describe Aoc::Day::Day23 do
  include Aoc

  input = "kh-tc
qp-kh
de-cg
ka-co
yn-aq
qp-ub
cg-tb
vc-aq
tb-ka
wh-tc
yn-cg
kh-ub
ta-co
de-co
tc-td
tb-wq
wh-td
ta-ka
td-qp
aq-cg
wq-ub
ub-vc
de-ta
wq-aq
wq-vc
wh-yn
ka-de
kh-ta
co-tc
wh-qp
tb-vc
td-yn"
  day = Aoc::Day::Day23.new(input)

  it "solves part 1 correctly" do
    expect(day.part1).to equal(7)
  end

  it "solves part 2 correctly" do
    expect(day.part2).to eq("co,de,ka,ta")
  end
end
