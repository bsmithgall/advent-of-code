require_relative "../day"

module Aoc::Day
  class Day1
    include Aoc::Day

    def initialize(input)
      @input = input.strip.split("\n").map { |l| l.split().map { |c| c.to_i } }
    end

    def part1
      first, second = [], []
      @input.each do |(one, two)|
        first.append(one)
        second.append(two)
      end

      first.sort.zip(second.sort).reduce(0) do |acc, (one, two)|
        acc + (one - two).abs()
      end
    end

    def part2
      count_map = @input.reduce(Hash.new) do |acc, (_, c)|
        acc[c] = acc.fetch(c, 0) + 1
        acc
      end

      @input.reduce(0) { |acc, (c, _)| acc + c * count_map.fetch(c, 0) }
    end
  end
end
