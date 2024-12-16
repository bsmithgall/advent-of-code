require_relative "../../../lib/aoc/days/day16"

RSpec.describe Aoc::Day::Day16 do
  include Aoc

  input = "###############
#.......#....E#
#.#.###.#.###.#
#.....#.#...#.#
#.###.#####.#.#
#.#.#.......#.#
#.#.#####.###.#
#...........#.#
###.#.#####.#.#
#...#.....#.#.#
#.#.#.###.#.#.#
#.....#...#.#.#
#.###.#.#.#.#.#
#S..#.....#...#
###############"
  day = Aoc::Day::Day16.new(input)

  it "solves part 1 correctly" do
    expect(day.part1).to equal(7036)
  end

  it "solves part 2 correctly" do
    expect(day.part2).to equal(45)
  end
end
