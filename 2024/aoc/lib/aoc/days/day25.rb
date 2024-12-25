require_relative "../day"

module Aoc::Day
  class Day25
    include Aoc::Day

    def initialize(input)
      @locks, @keys = [], []

      input.split("\n\n").each do |l|
        lines = l.split("\n")
        is_lock = lines[0].chars.all? { |c| c == "#" }
        heights = lines[0].chars.each_index.reduce([]) do |acc, idx|
          acc.push(lines.map { |l| l[idx] }.filter { |c| c == "#" }.count - 1)
        end
        is_lock ? @locks.push(heights) : @keys.push(heights)
      end
    end

    def part1
      fits = Set.new
      @locks.each do |lock|
        @keys.each do |key|
          fits.add([lock, key]) if lock.zip(key).map(&:sum).all? { |s| s < 6 }
        end
      end

      fits.length
    end

    def part2
    end
  end
end