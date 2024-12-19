require_relative "../../../lib/aoc/days/day19"

RSpec.describe Aoc::Day::Day19 do
  include Aoc

  input = "r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb"
  day = Aoc::Day::Day19.new(input)

  it "solves part 1 correctly" do
    expect(day.part1).to equal(6)
  end

  it "solves part 2 correctly" do
    expect(day.part2).to equal(16)
  end
end
