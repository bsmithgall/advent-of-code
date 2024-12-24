require_relative "../day"

module Setpop
  refine Set do
    def pop
      el = to_a.sample
      delete(el)
      el
    end
  end
end

module Aoc::Day
  class Day23
    include Aoc::Day
    using Setpop

    def initialize(input)
      @connections = input.split("\n")
        .map { |l| l.split("-") }
        .reduce(Hash.new { |h, k| h[k] = Set.new }) do |acc, (l, r)|
        acc[l].add(r)
        acc[r].add(l)
        acc
      end
    end

    def part1
      triples.filter { |t| t.any? { |c| c.start_with?("t") } }.length
    end

    def part2
      most_interconnected(@connections.keys).to_a.sort.join(",")
    end

    def triples
      @connections.reduce(Set.new) do |acc, (c1, c1_connections)|
        c1_connections.each do |c2|
          (c1_connections.intersection(@connections[c2])).each do |c3|
            acc.add([c1, c2, c3].sort)
          end
        end
        acc
      end
    end

    def most_interconnected(remaining, current = Set.new, best = Set.new)
      return best if current.length + remaining.length < best.length

      best = current.length >= best.length ? current : best

      until remaining.empty?
        r = remaining.pop
        best = most_interconnected(@connections[r].intersection(remaining), current.clone.add(r), best)
      end

      best
    end
  end
end
