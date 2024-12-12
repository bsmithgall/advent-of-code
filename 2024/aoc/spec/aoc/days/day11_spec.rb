require_relative "../../../lib/aoc/days/day11"

RSpec.describe Aoc::Day::Day11 do
  include Aoc

  input = "125 17"
  day = Aoc::Day::Day11.new(input)

  it "solves part 1 correctly" do
    expect(day.part1).to equal(55312)
  end
end
