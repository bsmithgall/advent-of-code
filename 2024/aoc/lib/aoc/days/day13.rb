require_relative "../day"

module Aoc::Day
  class Day13
    include Aoc::Day

    def initialize(input)
      @claws = input.split("\n\n").map { |str| Claw.new(str) }
    end

    def part1
      @claws.map { |c| c.cheapest_win }.filter { |v| v != Float::MAX }.sum
    end

    def part2
      @claws.map { |c| c.cheapest_big_prize_win }.filter { |n| !n.nil? }.sum
    end
  end

  class Claw
    def initialize(input)
      @a, @b, @prize = input.split("\n").map { |s| s.scan(/\d+/).map(&:to_i) }
      @big_prize = @prize.map { |p| p + 10000000000000 }
      @memo = Hash.new
    end

    def cheapest_win(prize_x = @prize[0], prize_y = @prize[1], a_presses = 0, b_presses = 0)
      return Float::MAX if prize_x < 0 or prize_y < 0 or a_presses > 100 or b_presses > 100

      return a_presses * 3 + b_presses if prize_x == 0 and prize_y == 0

      @memo[[prize_x - @a[0], prize_y - @a[1], a_presses + 1, b_presses]] ||= cheapest_win(prize_x - @a[0], prize_y - @a[1], a_presses + 1, b_presses)
      @memo[[prize_x - @b[0], prize_y - @b[1], a_presses, b_presses + 1]] ||= cheapest_win(prize_x - @b[0], prize_y - @b[1], a_presses, b_presses + 1)

      [
        @memo[[prize_x - @a[0], prize_y - @a[1], a_presses + 1, b_presses]],
        @memo[[prize_x - @b[0], prize_y - @b[1], a_presses, b_presses + 1]],
      ].min
    end

    def cheapest_big_prize_win
      # everyone loves cramer
      an = @big_prize[0] * @b[1] - @b[0] * @big_prize[1]
      ad = @a[0] * @b[1] - @b[0] * @a[1]

      bn = @big_prize[0] * @a[1] - @a[0] * @big_prize[1]
      bd = @b[0] * @a[1] - @a[0] * @b[1]

      return nil if ad == 0 or bd == 0

      return nil if an % ad != 0 or bn % bd != 0

      a = an / ad
      b = bn / bd

      return a * 3 + b
    end
  end
end
