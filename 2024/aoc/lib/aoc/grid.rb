module Aoc
  class Grid
    attr_reader :w, :h, :points, :dirs, :diags, :all_dirs

    def initialize(str, map_fn = :itself)
      @dirs = {
        w: [-1, 0],
        e: [1, 0],
        n: [0, -1],
        s: [0, 1],
      }
      @diags = {
        nw: [-1, -1], # up-left
        ne: [-1, 1], # up-right
        sw: [1, -1], # down-left
        se: [1, 1], # down-right
      }
      @all_dirs = @dirs.merge(@diags)

      lines = str.strip.split("\n")
      @h = lines.length - 1
      @w = lines.map(&:length).max - 1
      @points = lines.map { |l| l.split("").map(&map_fn) }
    end

    def in_bounds?(x, y)
      x >= 0 and x <= @w and y >= 0 and y <= @h
    end

    def at(x, y) = in_bounds?(x, y) ? @points[y][x] : nil

    def set(x, y, v) = @points[y][x] = v

    def rows = (0..@h)
    def cols = (0..@w)

    def find(v)
      rows.each do |y|
        cols.each do |x|
          if @points[x][y] == v
            return [y, x]
          end
        end
      end

      nil
    end

    def find_all(v)
      rows.reduce([]) do |acc, y|
        cols.reduce(acc) do |acc, x|
          at(x, y) == v ? acc << [x, y] : acc
        end
      end
    end

    def step(pos, dir)
      pos.zip(@dirs[dir]).map(&:sum)
    end
  end
end
