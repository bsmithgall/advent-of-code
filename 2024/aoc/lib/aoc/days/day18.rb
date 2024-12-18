require_relative "../day"
require_relative "../grid"
require_relative "./day16"

module Aoc::Day
  class Day18
    include Aoc::Day

    def initialize(input, size = 71, limit = 1024)
      @input = input
      @limit = limit
      @computer = CorruptingComputer.new(input, size, limit)
    end

    def part1
      @computer.find_best_path.score
    end

    def part2
      best_path = @computer.find_best_path
      @computer.rest.each do |(x, y)|
        @computer.block(x, y)
        if (best_path.path.include?([x, y]))
          best_path = @computer.find_best_path
          return "#{x},#{y}" if best_path.nil?
        end
      end
    end
  end

  class CorruptingComputer < Aoc::Grid
    attr_reader :rest

    def initialize(input, size, limit)
      super("junk\n")

      @w, @h = size - 1, size - 1
      @points = Array.new(size).map { |_| Array.new(size).fill(".") }
      start = input.split("\n").take(limit).map { |p| p.split(",").map(&:to_i) }
      @rest = input.split("\n").drop(limit).map { |p| p.split(",").map(&:to_i) }

      start.each { |(x, y)| @points[y][x] = "#" }
    end

    def block(x, y)
      @points[y][x] = "#"
    end

    def find_best_path
      visited = Set.new
      frontier = candidates(Path.new(0, [0, 0], nil, Set.new([[0, 0]])), visited)

      frontier.each { |p| visited.add(p.pos) }

      while !frontier.empty?
        nextpath = frontier.shift

        return nextpath if nextpath.pos == [@w, @h]

        candidates(nextpath, visited)
          .each { |p| visited.add(p.pos) }
          .each { |p| frontier.push(p) }
      end

      nil
    end

    def candidates(path, visited)
      @dirs.keys.map { |dir| step(path.pos, dir) }
        .filter do |np|
        val = at(*np)
        !val.nil? && val != "#" and !visited.include?(np)
      end
        .map { |np| Path.new(path.score + 1, np, nil, path.path.clone.add(np)) }
    end
  end
end
