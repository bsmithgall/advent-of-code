require_relative "../../../lib/aoc/days/day1"

RSpec.describe Aoc::Day::Day1 do
  include Aoc

  input = "3   4
4   3
2   5
1   3
3   9
3   3
  "
  day = Aoc::Day::Day1.new(input)

  it "solves part 1 correctly" do
    expect(day.part1).to equal(11)
  end

  it "solves part 2 correctly" do
    expect(day.part2).to equal(31)
  end
end
