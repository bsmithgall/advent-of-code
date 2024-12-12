require_relative "../../../lib/aoc/days/day12"

RSpec.describe Aoc::Day::Day12 do
  include Aoc

  input = "RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE"
  day = Aoc::Day::Day12.new(input)

  it "solves part 1 correctly" do
    expect(day.part1).to equal(1930)
  end

  it "solves part 2 correctly" do
    expect(day.part2).to equal(1206)
  end
end
