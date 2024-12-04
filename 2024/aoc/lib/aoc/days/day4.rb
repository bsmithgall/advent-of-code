require_relative "../day"

module Aoc::Day
  class Day4
    include Aoc::Day

    def initialize(input)
      @input = input.strip.split("\n").map { |l| l.split("") }
      @dirs = [
        [-1, 0], # up
        [1, 0], # down
        [0, -1], # left
        [0, 1], # right
        [-1, -1], # up-left
        [-1, 1], # up-right
        [1, -1], # down-left
        [1, 1], # down-right
      ]
    end

    def part1
      xmases = 0

      @input.each_index do |row|
        @input[0].each_index do |col|
          @dirs.each do |dir|
            if xmasable?(row, col, dir) and xmas?(row, col, dir)
              xmases += 1
            end
          end
        end
      end

      xmases
    end

    def part2
      x_dash_mases = 0

      @input.each_index do |row|
        @input[0].each_index do |col|
          if x_dash_masable?(row, col) and mas?(row, col)
            x_dash_mases += 1
          end
        end
      end

      x_dash_mases
    end

    def xmasable?(row, col, (dirRow, dirCol))
      row + 3 * dirRow < @input.length and row + 3 * dirRow >= 0 and
      col + 3 * dirCol < @input.length and col + 3 * dirCol >= 0
    end

    def xmas?(row, col, (dirRow, dirCol))
      (0..3).reduce("") { |acc, idx| acc + @input[row + idx * dirRow][col + idx * dirCol] } == "XMAS"
    end
  end

  def x_dash_masable?(row, col)
    row >= 1 and row < @input.length - 1 and col >= 1 and col < @input[0].length - 1
  end

  def mas?(row, col)
    @input[row][col] == "A" and
    ["SM", "MS"].include?(@input[row - 1][col - 1] + @input[row + 1][col + 1]) and
      ["SM", "MS"].include?(@input[row - 1][col + 1] + @input[row + 1][col - 1])
  end
end
