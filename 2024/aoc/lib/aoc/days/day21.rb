require_relative "../day"
require_relative "../grid"

module Aoc::Day
  class Day21
    include Aoc::Day
    NUMPAD = Aoc::Grid.new("789\n456\n123\n#0A")
    KEYPAD = Aoc::Grid.new("#^A\n<v>")

    def initialize(input)
      @input = input.split("\n").map { |l| [l[0..2].to_i, l] }
      @memo = Hash.new
    end

    def part1
      @input.map { |(n, seq)| n * find_sequence_length(seq, 2, NUMPAD, NUMPAD) }.sum
    end

    def part2
      @input.map { |(n, seq)| n * find_sequence_length(seq, 25, NUMPAD, NUMPAD) }.sum
    end

    def find_sequence_length(seq, robot, pad = KEYPAD, gpad = KEYPAD)
      return seq.length if robot < 0

      result = 0

      keypairs(seq).each do |(one, two)|
        @memo[[one, two, pad, robot]] ||= min_path(one, two, gpad, robot)
        result += @memo[[one, two, pad, robot]]
      end

      result
    end

    def min_path(one, two, pad, robot)
      x1, y1 = pad.find(one)
      x2, y2 = pad.find(two)

      x_dist = x2 - x1
      y_dist = y2 - y1

      from_one = pad.step_by(pad.find(one), [x_dist, 0])
      from_two = pad.step_by(pad.find(two), [-x_dist, 0])

      [
        [pad.at(*from_one), "#{leftright(x_dist)}#{updown(y_dist)}A"],
        [pad.at(*from_two), "#{updown(y_dist)}#{leftright(x_dist)}A"],
      ]
        .filter { |(pos, _)| pos != "#" }
        .flat_map { |(_, seq)| find_sequence_length(seq, robot - 1) }
        .min
    end

    def keypairs(seq)
      "A#{seq}".split("").zip(seq.split(""))
        .filter { |(a, b)| !a.nil? && !b.nil? }
    end

    def updown(y_dist)
      (y_dist > 0 ? "v" : "^") * y_dist.abs
    end

    def leftright(x_dist)
      (x_dist > 0 ? ">" : "<") * x_dist.abs
    end
  end
end
