require_relative "../../../lib/aoc/days/day4"

RSpec.describe Aoc::Day::Day4 do
  include Aoc

  input = "
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
"
  day = Aoc::Day::Day4.new(input)

  it "solves part 1 correctly" do
    expect(day.part1).to equal(18)
  end

  it "solves part 2 correctly" do
    expect(day.part2).to equal(9)
  end
end
