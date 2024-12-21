require_relative "../../../lib/aoc/days/day21"

RSpec.describe Aoc::Day::Day21 do
  include Aoc

  input = "029A
980A
179A
456A
379A"
  day = Aoc::Day::Day21.new(input)

  it "solves part 1 correctly" do
    expect(day.part1).to equal(126384)
  end
end
