require_relative "../../../lib/aoc/days/day9"

RSpec.describe Aoc::Day::Day9 do
  include Aoc

  input = "2333133121414131402"
  day = Aoc::Day::Day9.new(input)

  it "solves part 1 correctly" do
    expect(day.part1).to equal(1928)
  end

  it "solves part 2 correctly" do
    expect(day.part2).to equal(2858)
  end
end
