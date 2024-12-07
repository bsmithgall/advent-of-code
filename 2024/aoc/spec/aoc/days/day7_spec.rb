require_relative "../../../lib/aoc/days/day7"

RSpec.describe Aoc::Day::Day7 do
  include Aoc

  input = "190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20
"
  day = Aoc::Day::Day7.new(input)

  it "solves part 1 correctly" do
    expect(day.part1).to equal(3749)
  end

  it "solves part 2 correctly" do
    expect(day.part2).to equal(11387)
  end
end
