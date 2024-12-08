require_relative "../day"
require_relative "../grid"

module Aoc::Day
  class Day8
    include Aoc::Day

    def initialize(input)
      @antenna = Antenna.new(input)
    end

    def part1
      antinodes = Set.new
      @antenna.frequencies.values.each do |freq|
        freq.combination(2).each do |points|
          @antenna.antinodes(points).each { |a| antinodes.add(a) }
        end
      end
      antinodes.length
    end

    def part2
      antinodes = Set.new(@antenna.locs)
      @antenna.frequencies.values.each do |freq|
        freq.combination(2).each do |points|
          @antenna.all_antinodes(points).each { |a| antinodes.add(a) }
        end
      end
      antinodes.length
    end
  end

  class Antenna < Aoc::Grid
    attr_reader :frequencies, :locs

    def initialize(input)
      super(input)
      @frequencies = Hash.new { |h, k| h[k] = [] }

      rows.each do |y|
        cols.each do |x|
          val = at(x, y)
          @frequencies[val].push([x, y]) if val != "."
        end
      end

      @locs = Set.new(@frequencies.values.flatten(1))
    end

    def antinodes(((x1, y1), (x2, y2)))
      xdif = (x2 - x1).abs()
      xmin, xmax = [x1, x2].sort!

      m = slope([x1, y1], [x2, y2])
      b = intercept([x1, y1], m)

      [[xmin - xdif, m * (xmin - xdif) + b],
       [xmax + xdif, m * (xmax + xdif) + b]]
        .map { |(x, y)| [x.round, y.round] }
        .filter { |pt| in_bounds?(*pt) }
    end

    def all_antinodes(((x1, y1), (x2, y2)))
      xdif = (x2 - x1).abs()
      xmin, xmax = [x1, x2].sort!

      m = slope([x1, y1], [x2, y2])
      b = intercept([x1, y1], m)

      (1..51).map do |i|
        [[xmin - xdif * i, m * (xmin - xdif * i) + b], [xmax + xdif * i, m * (xmax + xdif * i) + b]]
      end.flatten(1)
        .map { |(x, y)| [x.round, y.round] }
        .filter { |pt| in_bounds?(*pt) }
    end

    def slope(a, b)
      if b[0] - a[0] == 0
        nil
      else
        (b[1].to_f - a[1]) / (b[0] - a[0])
      end
    end

    def intercept((x, y), slope)
      return x if slope == nil

      y - slope * x
    end
  end
end
