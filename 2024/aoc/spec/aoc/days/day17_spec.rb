require_relative "../../../lib/aoc/days/day17"

RSpec.describe Aoc::Day::Day17 do
  include Aoc

  it "solves part 1 correctly" do
    input = "
Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0"
    day = Aoc::Day::Day17.new(input)

    expect(day.part1).to eq("4,6,3,5,6,3,5,2,1,0")
  end

  it "solves part 2 correctly" do
    input = "
Register A: 2024
Register B: 0
Register C: 0

Program: 0,3,5,4,3,0"
    day = Aoc::Day::Day17.new(input)

    expect(day.part2).to equal(117440)
  end
end
