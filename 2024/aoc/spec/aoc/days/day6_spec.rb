require_relative "../../../lib/aoc/days/day6"

RSpec.describe Aoc::Day::Day6 do
  include Aoc

  input = "....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
"
  day = Aoc::Day::Day6.new(input)

  it "solves part 1 correctly" do
    expect(day.part1).to equal(41)
  end

  it "solves part 2 correctly" do
    expect(day.part2).to equal(6)
  end
end
