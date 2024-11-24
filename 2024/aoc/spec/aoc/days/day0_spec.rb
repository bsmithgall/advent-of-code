require_relative "../../../lib/aoc/days/day0"

RSpec.describe Aoc::Day::Day0 do
  include Aoc

  input = Aoc.find_input(0)
  day = Aoc::Day::Day0.new(input)

  it "solves part 1 correctly" do
    expect(day.part1).to equal(3)
  end

  it "solves part 2 correctly" do
    expect(day.part2).to equal(2)
  end
end
