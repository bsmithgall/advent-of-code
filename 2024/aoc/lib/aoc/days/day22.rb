require_relative "../day"

module Evolver
  refine Integer do
    def evolve
      one.two.three
    end

    def mix(x)
      x ^ self
    end

    def prune
      self % 16777216
    end

    def one
      mix(self * 64).prune
    end

    def two
      mix(self / 32).prune
    end

    def three
      mix(self * 2048).prune
    end
  end
end

module Aoc::Day
  class Day22
    include Aoc::Day
    using Evolver

    def initialize(input)
      @input = input.split("\n").map(&:to_i)
    end

    def part1
      @input.map { |v| (1..2000).reduce(v) { |acc, _| acc.evolve } }.sum
    end

    def part2
      @input.reduce(Hash.new) do |acc, input|
        seq = FourSeq.new
        prev_ones = ones = input % 10
      
        acc.merge((1..2000).reduce(Hash.new) do |l, _|
          input = input.evolve
          ones = input % 10
          seq.append(ones - prev_ones)
          prev_ones = ones
          seq.full? ? l.update(seq.to_a => prev_ones) { |_, v1, v2| v1 } : l
        end) { |_, v1, v2| v1 + v2 }
      end.values.max
    end

    class FourSeq
      def initialize
        @arr = []
        @size = 4
      end

      def append(item)
        @arr.push(item)
        @arr.shift if @arr.length > @size
        self
      end

      def to_a
        @arr.clone
      end

      def full?
        @arr.length == @size
      end
    end
  end
end
