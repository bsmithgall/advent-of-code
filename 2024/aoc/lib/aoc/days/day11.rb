require_relative "../day"

module Aoc::Day
  class Day11
    include Aoc::Day

    def initialize(input)
      @stones = Stones.new(input)
    end

    def part1
      @stones.blink(25)
    end

    def part2
      @stones.blink(75)
    end
  end

  class Stones
    def initialize(input)
      @stones = input.split
      @memo = Hash.new
    end

    def blink(times)
      @stones.map { |s| _blink(s, times) }.sum
    end

    def _blink(value, count)
      return 1 if count == 0

      if value == "0"
        @memo[[value, count]] ||= _blink("1", count - 1)
      elsif even?(value)
        (l, r) = split(value)
        @memo[[value, count]] ||= _blink(l, count - 1) + _blink(r, count - 1)
      else
        @memo[[value, count]] ||= _blink((value.to_i * 2024).to_s, count - 1)
      end
    end

    def even?(value) = value.length % 2 == 0

    def split(value)
      (l, r) = value.chars.each_slice(value.length / 2).map(&:join)
      r = r.sub(/^0+/, "")
      [l, r.empty? ? "0" : r]
    end
  end
end
