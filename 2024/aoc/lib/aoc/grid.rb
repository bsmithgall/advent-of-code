module Aoc
  class Grid
    attr_reader :w, :h, :points, :dirs, :diags, :all_dirs

    def initialize(str, map_fn = :itself)
      @dirs = [
        [-1, 0], # up
        [1, 0], # down
        [0, -1], # left
        [0, 1], # right
      ]
      @diags = [
        [-1, -1], # up-left
        [-1, 1], # up-right
        [1, -1], # down-left
        [1, 1], # down-right
      ]

      lines = str.strip.split("\n")
      @h = lines.length - 1
      @w = lines.map(&:length).max - 1
      @points = lines.map { |l| l.split("").map(&map_fn) }
    end

    def in_bounds?(x, y)
      x >= 0 and x <= @w and y >= 0 and y <= @h
    end

    def at(x, y) = @points[y][x]

    def rows = (0..@h)
    def cols = (0..@w)
  end
end
