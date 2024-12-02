require_relative "../day"

module Aoc::Day
  class Day2
    include Aoc::Day

    def initialize(input)
      @input = input.strip.split("\n").map { |l| l.split().map(&:to_i) }
    end

    def part1
      @input.filter(&method(:safe_line?)).length
    end

    def part2
      @input.map do |line|
        line.each_index.map { |idx| line.reject.with_index { |_, jdx| jdx == idx } }.concat([line])
      end.filter { |lines| lines.any?(&method(:safe_line?)) }.length
    end
  end

  def safe_line?(line)
    pos, neg = false, false
    (0..line.length - 2).map do |idx|
      dist = line[idx] - line[idx + 1]
      if dist > 0
        pos = true
      else
        neg = true
      end

      return false if pos and neg
      return false if dist.abs < 1 or dist.abs > 3
    end

    true
  end
end
