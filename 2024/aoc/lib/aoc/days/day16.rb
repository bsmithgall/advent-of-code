require_relative "../day"
require_relative "../grid"

module Aoc::Day
  class Day16
    include Aoc::Day

    def initialize(input)
      @games = ReindeerGame.new(input)
    end

    def part1
      @games.stepthrough
    end

    def part2
      @games.stepthrough(true).length
    end
  end

  Path = Struct.new("Path", :score, :pos, :dir, :path)

  class ReindeerGame < Aoc::Grid
    def initialize(input)
      super(input)
      @start = find("S")
      @end = find("E")
    end

    def stepthrough(findall = false)
      visited = Set.new
      best_visited = Set.new
      best_score = Float::INFINITY
      frontier = candidates(Path.new(0, @start, :e, [@start]), visited)
      frontier.each { |p| visited.add([p.pos, p.dir]) }

      while !frontier.empty?
        nextpath = frontier.min_by { |p| p.score }

        frontier.delete(nextpath)
        visited.add([nextpath.pos, nextpath.dir])

        if nextpath.pos == @end and nextpath.score <= best_score
          best_visited.merge(nextpath.path)
          best_score = nextpath.score
        end

        return nextpath.score if nextpath.pos == @end and !findall

        candidates(nextpath, visited).each { |p| frontier.push(p) }
      end

      best_visited
    end

    def candidates(path, visited)
      @dirs.keys.map { |dir| [dir, step(path.pos, dir)] }
        .filter { |dir, np| at(*np) != "#" and !visited.include?([np, dir]) }
        .map { |dir, pos| Path.new(path.score + (dir == path.dir ? 1 : 1001), pos, dir, path.path.clone.push(pos)) }
    end
  end
end
