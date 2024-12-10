require_relative "../../../lib/aoc/days/day10"

RSpec.describe Aoc::Day::Day10 do
  include Aoc

  input = "89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732
"
  day = Aoc::Day::Day10.new(input)

  it "solves part 1 correctly" do
    expect(day.part1).to equal(36)
  end

  it "solves part 2 correctly" do
    expect(day.part2).to equal(81)
  end
end
