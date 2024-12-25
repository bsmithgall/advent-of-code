require_relative "../../../lib/aoc/days/day25"

RSpec.describe Aoc::Day::Day25 do
  include Aoc

  input = "#####
.####
.####
.####
.#.#.
.#...
.....

#####
##.##
.#.##
...##
...#.
...#.
.....

.....
#....
#....
#...#
#.#.#
#.###
#####

.....
.....
#.#..
###..
###.#
###.#
#####

.....
.....
.....
#....
#.#..
#.#.#
#####"
  day = Aoc::Day::Day25.new(input)

  it "solves part 1 correctly" do
    expect(day.part1).to equal(3)
  end
end