require_relative "../day"
require_relative "../grid"

module Aoc::Day
  class Day20
    attr_reader :computer

    include Aoc::Day

    def initialize(input)
      @computer = CheatComputer.new(input)
    end

    def part1
      @computer.find_cheats(2).filter { |_, v| v >= 100 }.count
    end

    def part2
      @computer.find_cheats(20).filter { |_, v| v >= 100 }.count
    end
  end

  class CheatComputer < Aoc::Grid
    attr_reader :path

    def initialize(input)
      super(input)
      @start = find("S")
      @end = find("E")

      @path = Hash.new
      @steps_from_start = 0

      walk_all_paths
    end

    def walk_all_paths
      frontier = [@start]

      while !frontier.empty?
        frontier.each { |pos| @path[pos] = @steps_from_start }
        frontier = frontier
          .flat_map { |pos| @dirs.keys.map { |dir| step(pos, dir) } }
          .filter { |np| at(*np) != "#" and !@path.include?(np) }
        @steps_from_start += 1
      end

      self
    end

    def find_cheats(size = 2)
      @path.reduce(Hash.new) do |acc, (path, from_start)|
        (-size..size).each do |x|
          (-size..size).each do |y|
            dist = x.abs + y.abs
            gain = @path.fetch([path[0] + x, path[1] + y], 0) - from_start - dist

            acc[[path, [path[0] + x, path[1] + y]]] = gain if gain > 0 and dist <= size
          end
        end
        acc
      end
    end
  end
end
