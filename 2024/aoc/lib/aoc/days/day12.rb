require_relative "../day"
require_relative "../grid"

module Aoc::Day
  class Day12
    include Aoc::Day

    def initialize(input)
      @garden = Garden.new(input)
    end

    def part1
      @garden.plots.map { |p| @garden.size(p) * p.length }.sum
    end

    def part2
      @garden.plots.map { |p| @garden.sides(p) * p.length }.sum
    end
  end

  class Garden
    attr_reader :plots

    def initialize(input)
      @plants = input.strip.split("\n").each.with_index.reduce(Hash.new) do |acc, (row, idy)|
        row.split("").each.with_index.reduce(acc) do |acc, (val, idx)|
          acc[[idx, idy]] = val
          acc
        end
      end
      @plots = consolidate
    end

    def consolidate
      areas = []

      plants = @plants.clone
      while !plants.empty?
        coord, plant = plants.to_enum.next
        expanding = area = Set.new([coord])

        while !expanding.empty?
          expanding = Set.new(area.flat_map { |pos| neighbors(pos).filter { |coord| plants[coord] == plant } }) - area
          area = area.merge(expanding)
        end

        areas.push(area)
        plants = plants.filter { |k, v| !area.include?(k) }
      end
      areas
    end

    def size(plot)
      plot.reduce(0) { |acc, loc| acc + neighbors(loc).filter { |n| !plot.include?(n) }.length }
    end

    def sides(plot)
      s = 0

      plot.each do |p|
        corners.each do |(x, y)|
          c1 = plot.include?(step(p, [x, y]))
          c2 = plot.include?(step(p, [x, 0]))
          c3 = plot.include?(step(p, [0, y]))

          s += 1 if (c2 == c3 and !(c1 and c2))
        end
      end

      s
    end

    def dirs
      [[-1, 0], [1, 0], [0, -1], [0, 1]]
    end

    def corners
      dirs + [[-1, -1], [1, 1], [-1, 1], [1, -1]]
    end

    def neighbors(pos)
      dirs.map { |d| step(pos, d) }
    end

    def step(pos, dir)
      pos.zip(dir).map(&:sum)
    end

  end
end
