require_relative "../day"
require_relative "../grid"

module Aoc::Day
  class Day10
    include Aoc::Day

    def initialize(input)
      @hiking = Hiking.new(input)
    end

    def part1
      @hiking.walk_up_all.flat_map(&:keys).length
    end

    def part2
      @hiking.walk_up_all.flat_map(&:values).sum
    end
  end

  class Hiking < Aoc::Grid
    def initialize(input)
      super(input, ->(i) { i == "." ? -1 : i.to_i })
    end

    def walk_up_all
      find_all(0).map(&method(:trailhead_score))
    end

    def trailhead_score(orig)
      score = Hash.new { |h, k| h[k] = 0 }
      candidates = [[orig, 0]]
      while !candidates.empty?
        (pos, next_) = candidates.pop

        score[pos] += 1 if next_ == 9

        @dirs.keys.each do |dir|
          step = step(pos, dir)
          stepped = at(*step)
          candidates.push([step, next_ + 1]) if stepped == next_ + 1
        end
      end
      score
    end
  end
end
