require_relative "../day"
require_relative "../grid"

module Aoc::Day
  class Day6
    include Aoc::Day

    def initialize(input)
      @input = input
      @grid = Guard.new(input)
    end

    def part1
      @grid.walk
    end

    def part2
      count = 0

      @grid.walk
      @grid.visited_pos.each_with_index do |(x, y), idx|
        g = Guard.new(@input)

        if [x, y] == g.pos
          next
        end

        g.set(x, y, "#")

        if g.walk_in_loop?
          count += 1
        end
      end

      count
    end
  end

  class Guard < Aoc::Grid
    attr_reader :pos, :visited_pos

    def initialize(input)
      super(input)
      @pos = find("^")
      @dir = :n
      @visited_pos = Set.new([@pos])
      @visited = Set.new([[@pos, @dir]])
      @next_dir = { n: :e, e: :s, s: :w, w: :n }
    end

    def walk
      while in_bounds?(*@pos)
        @pos, @dir, val = next_step
        if val != nil
          @visited_pos.add(@pos)
        end
      end

      @visited_pos.length
    end

    def walk_in_loop?
      while in_bounds?(*@pos)
        pos, dir, _ = next_step
        if @visited.include?([pos, dir])
          return true
        end

        @visited.add([@pos, @dir])
        @visited_pos.add(@pos)
        @pos = pos
        @dir = dir
      end

      false
    end

    def next_step
      pos, dir = @pos, @dir
      while true
        next_pos = next_(dir)
        val = at(*next_pos)
        if val == "#"
          dir = @next_dir[dir]
        else
          pos = next_pos
          break
        end
      end
      [pos, dir, val]
    end

    def next_(dir = @dir)
      @pos.zip(@dirs[dir]).map(&:sum)
    end
  end
end
