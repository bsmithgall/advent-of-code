require_relative "../day"

class Integer
  def concat(other)
    (self.to_s + other.to_s).to_i
  end
end

module Aoc::Day
  class Day7
    include Aoc::Day

    def initialize(input)
      @input = input.strip.split("\n").map { |l| l.split(": ") }.map { |(ans, parts)| [ans.to_i, parts.split.map(&:to_i)] }
    end

    def part1
      @input.filter(&method(:solvable?)).map(&:first).sum
    end

    def part2
      @input.filter { |l| solvable?(l, true) }.map(&:first).sum
    end

    def solvable?((expected, parts), calibrate = false)
      to_check = [parts]
      while not to_check.empty?
        checking = to_check.pop

        if checking.length == 2
          a, b = checking
          sums = expected == a + b
          mults = expected == a * b
          calibrates = expected == a.concat(b)

          return true if sums or mults
          return true if calibrate and calibrates
        else
          a, b, *rest = checking
          to_check.push([a + b] + rest)
          to_check.push([a * b] + rest)
          to_check.push([a.concat(b)] + rest) if calibrate
        end
      end
      false
    end
  end
end
