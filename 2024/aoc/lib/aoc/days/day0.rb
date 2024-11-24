require_relative "../../aoc"
require_relative "../day"

module Aoc::Day
  class Day0
    include Aoc::Day

    def initialize(input)
      @input = input.split("\n").map { |s| s.to_i }
    end

    def part1
      @input.reduce(:+)
    end

    def part2
      @input.reduce(1, :*)
    end
  end
end
