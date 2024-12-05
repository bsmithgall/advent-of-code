require_relative "../day"

module Aoc::Day
  class Day5
    include Aoc::Day

    def initialize(input)
      rules, updates = input.split("\n\n")
      @rules = Set.new(rules.split("\n").map { |r| r.split("|").map(&:to_i) })
      @updates = updates.split("\n").map { |p| p.split(",").map(&:to_i) }
      @rule_map = @rules.reduce(Hash.new { |h, k| h[k] = Hash[after: Set.new, before: Set.new] }) do |acc, (k, v)|
        acc[k][:after].add(v)
        acc[v][:before].add(k)
        acc
      end
    end

    def part1
      @updates.filter(&method(:valid_update?)).map(&method(:midpoint)).sum
    end

    def part2
      @updates.filter(&method(:invalid_update)).map(&method(:to_valid)).map(&method(:midpoint)).sum
    end

    def valid_update?(update)
      update.each_with_index.all? do |v, idx|
        before_valid = (0..idx - 1).all? { |jdx| @rule_map[update[jdx]][:after].include?(v) }
        after_valid = (idx + 1..update.length - 1).all? { |jdx| @rule_map[update[jdx]][:before].include?(v) }

        before_valid and after_valid
      end
    end

    def invalid_update(update) = not valid_update?(update)

    def to_valid(invalid)
      invalid.sort { |a, b| @rules.include?([a, b]) ? -1 : 1 }
    end

    def midpoint(update) = update[update.length / 2]
  end
end
