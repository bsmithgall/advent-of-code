require_relative "../day"

module Aoc::Day
  class Day3
    include Aoc::Day

    def initialize(input)
      @input = input
      @re = /mul\((\d+),(\d+)\)/
    end

    def part1
      @input.scan(@re).map { |(one, two)| one.to_i * two.to_i }.sum
    end

    def part2
      dos = @input.enum_for(:scan, /do\(\)/).map { [true, Regexp.last_match.begin(0)] }
      donts = @input.enum_for(:scan, /don\'t\(\)/).map { [false, Regexp.last_match.begin(0)] }
      matches = @input.enum_for(:scan, @re).map { [Regexp.last_match, Regexp.last_match.begin(0)] }

      doing = true
      output = 0

      (dos + donts + matches).sort_by { |el| el[1] }.each do |(whatis, _)|
        if whatis == true
          doing = true
        elsif whatis == false
          doing = false
        else
          output = output + whatis[1].to_i * whatis[2].to_i if doing
        end
      end

      output
    end
  end
end
