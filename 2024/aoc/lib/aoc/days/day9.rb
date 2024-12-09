require_relative "../day"

module Aoc::Day
  class Day9
    include Aoc::Day

    def initialize(input)
      @raw = input.split("").map(&:to_i)
    end

    def part1
      Defrag.new(@raw).defrag.checksum
    end

    def part2
      FileDefrag.new(@raw).defrag.checksum
    end
  end

  class Defrag
    def initialize(input)
      @min = Float::INFINITY
      @max = -Float::INFINITY
      @empty = []
      @full = []
      @data = {}

      pos, id, data = [0, 0, true]
      input.each do |el|
        if data
          (pos..pos + el - 1).each { |p| @data[p] = id }
          data = false
        else
          (pos..pos + el - 1).each do |p|
            @data[p] = nil
            @min = p if p < @min
            @max = p if p > @max
          end

          data = true
          id += 1
        end
        pos += el
      end

      @data.each do |k, v|
        @empty.prepend(k) if v == nil
        @full.push(k) if v != nil
      end
    end

    def defrag
      while defragable?
        next_empty = @empty.pop
        next_full = @full.pop

        @data[next_empty] = @data[next_full]
        @data[next_full] = nil

        @empty.prepend(next_full)
        @full.prepend(next_empty)

        @max = next_full if next_full > @max
        @min = @empty.last
      end

      self
    end

    def defragable?
      @max - @min > @empty.length
    end

    def checksum
      @data.reduce(0) { |acc, (k, v)| v == nil ? acc : acc + (k * v) }
    end
  end

  class FileDefrag < Defrag
    def initialize(input)
      pos, id, data = [0, 0, true]
      @data = []
      @empty = []
      @full = []

      input.each do |el|
        range = pos..pos + el - 1
        if data
          @full.prepend(range) if el > 0
          @data = @data.concat([id] * el)
          data = false
        else
          @empty.push(range) if el > 0 if el > 0
          @data = @data.concat([nil] * el)
          data = true
          id += 1
        end
        pos += el
      end
    end

    def defrag
      while true
        next_fit = find_next_fit
        return self if next_fit == nil

        empty_idx, full_idx = next_fit
        empty, full = [@empty[empty_idx], @full[full_idx]]
        left = empty.size - full.size

        empty.zip(full).each { |(e, f)| @data[e] = f }
        empty.zip(full).each do |e, f|
          @data[e] = @data[f] unless f.nil?
          @data[f] = nil unless f.nil?
        end

        if left != 0
          @empty[empty_idx] = empty.max - left + 1..empty.max
        else
          @empty.delete_at(empty_idx)
        end

        @full.delete_at(full_idx)
        @full.push(empty.min..empty.max - left)
      end
    end

    def find_next_fit
      @full.each_index do |idf|
        next_empty = @empty.each_index.lazy.find do |ide|
          full, empty = @full[idf], @empty[ide]
          full.size <= empty.size and full.min > empty.min
        end
        return [next_empty, idf] unless next_empty.nil?
      end
      nil
    end

    def checksum
      @data.each_with_index.reduce(0) { |acc, (v, idx)| v == nil ? acc : acc + idx * v }
    end
  end
end
