require_relative "../../../lib/aoc/days/day20"

RSpec.describe Aoc::Day::Day20 do
  include Aoc

  input = "###############
#...#...#.....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#######.#.#.###
#######.#.#...#
#######.#.###.#
###..E#...#...#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############
"
  day = Aoc::Day::Day20.new(input)

  it "solves part 1 correctly" do
    cheat_counts = day.computer.find_cheats(2).values.group_by(&:itself)

    expect(cheat_counts[2].length).to eq(14)
    expect(cheat_counts[64].length).to eq(1)
  end

  it "solves part 2 correctly" do
    cheat_counts = day.computer.find_cheats(20).values.group_by(&:itself)

    expect(cheat_counts[50].length).to eq(32)
    expect(cheat_counts[76].length).to eq(3)
  end
end
