require_relative "../../../lib/aoc/days/day18"

RSpec.describe Aoc::Day::Day18 do
  include Aoc

  input = "5,4
4,2
4,5
3,0
2,1
6,3
2,4
1,5
0,6
3,3
2,6
5,1
1,2
5,5
2,5
6,5
1,4
0,4
6,4
1,1
6,1
1,0
0,5
1,6
2,0"
  day = Aoc::Day::Day18.new(input, 7, 12)

  it "solves part 1 correctly" do
    expect(day.part1).to equal(22)
  end

  it "solves part 2 correctly" do
    expect(day.part2).to eq("6,1")
  end
end
