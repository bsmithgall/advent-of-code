require_relative "../../../lib/aoc/days/day2"

RSpec.describe Aoc::Day::Day2 do
  include Aoc

  input = "7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
"
  day = Aoc::Day::Day2.new(input)

  it "solves part 1 correctly" do
    expect(day.part1).to equal(2)
  end

  it "solves part 2 correctly" do
    expect(day.part2).to equal(4)
  end
end
