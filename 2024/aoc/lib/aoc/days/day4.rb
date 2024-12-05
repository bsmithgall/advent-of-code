require_relative "../day"
require_relative "../grid"

module Aoc::Day
  class Day4
    include Aoc::Day

    def initialize(input)
      @grid = XmasGrid.new(input)
    end

    def part1
      xmases = 0

      @grid.rows.each do |y|
        @grid.cols.each do |x|
          (@grid.dirs + @grid.diags).each do |dir|
            if @grid.xmasable?(x, y, dir) and @grid.xmas?(x, y, dir)
              xmases += 1
            end
          end
        end
      end

      xmases
    end

    def part2
      x_dash_mases = 0

      @grid.rows.each do |y|
        @grid.cols.each do |x|
          if @grid.masable?(x, y) and @grid.mas?(x, y)
            x_dash_mases += 1
          end
        end
      end

      x_dash_mases
    end
  end

  class XmasGrid < Aoc::Grid
    def xmasable?(x, y, (xDir, yDir))
      in_bounds?(x + 3 * xDir, y + 3 * yDir)
    end

    def xmas?(x, y, (xDir, yDir))
      (0..3).reduce("") { |acc, idx| acc + at(x + idx * xDir, y + idx * yDir) } == "XMAS"
    end

    def masable?(x, y)
      x >= 1 and x < @w and y >= 1 and y < @h
    end

    def mas?(x, y)
      at(x, y) == "A" and ["SM", "MS"].include?(at(x - 1, y - 1) + at(x + 1, y + 1)) and ["SM", "MS"].include?(at(x - 1, y + 1) + at(x + 1, y - 1))
    end
  end
end
