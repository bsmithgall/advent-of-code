require_relative "../../../lib/aoc/days/day3"

RSpec.describe Aoc::Day::Day3 do
  include Aoc

  it "solves part 1 correctly" do
    input = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"
    day = Aoc::Day::Day3.new(input)
    expect(day.part1).to equal(161)
  end

  it "solves part 2 correctly" do
    input = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"
    day = Aoc::Day::Day3.new(input)
    expect(day.part2).to equal(48)
  end
end
