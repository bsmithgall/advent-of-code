require_relative "../../../lib/aoc/days/day22"

RSpec.describe Aoc::Day::Day22 do
  include Aoc

  it "solves part 1 correctly" do
  input = "1
10
100
2024"
  day = Aoc::Day::Day22.new(input)

    expect(day.part1).to equal(37327623)
  end

  it "solves part 2 correctly" do
  input = "1
2
3
2024"
  day = Aoc::Day::Day22.new(input)
    expect(day.part2).to equal(23)
  end
end
