require_relative "../../../lib/aoc/days/day13"

RSpec.describe Aoc::Day::Day13 do
  include Aoc

  input = "Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279
"
  day = Aoc::Day::Day13.new(input)

  it "solves part 1 correctly" do
    expect(day.part1).to equal(480)
  end

  it "solves part 2 correctly" do
    expect(day.part2).to equal(875318608908)
  end
end
