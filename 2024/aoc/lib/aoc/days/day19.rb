require_relative "../day"

module Aoc::Day
  class Day19
    include Aoc::Day

    def initialize(input)
      towels, patterns = input.strip.split("\n\n")
      @towels = towels.split(", ")
      @patterns = patterns.split("\n")
      @memo = Hash.new
    end

    def part1
      @patterns.map { |t| solve(t) }.filter { |c| c > 0 }.count
    end

    def part2
      @patterns.map { |t| solve(t) }.sum
    end

    def solve(part)
      return 1 if part.empty?

      @towels
        .filter { |pattern| part.start_with?(pattern) }
        .map { |pattern| @memo[part[pattern.length..]] ||= solve(part[pattern.length..]) }
        .sum
    end
  end
end
