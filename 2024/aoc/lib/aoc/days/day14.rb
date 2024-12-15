require_relative "../day"

module Aoc::Day
  class Day14
    include Aoc::Day

    def initialize(input, bounds = [101, 103])
      @input = input
      @bounds = bounds
    end

    def part1
      Robots.new(@input, @bounds).ticks(100).factor
    end

    def part2
      r = Robots.new(@input, @bounds)
      ticks = 0

      while !r.unique_position?
        r.tick
        ticks += 1
      end

      puts r.inspect

      ticks
    end
  end

  class Robots
    attr_reader :robots

    def initialize(input, bounds)
      @bounds = bounds
      @robots = input.split("\n").map { |line| Robot.new(line, bounds) }
      @positions = positions()
    end

    def inspect
      str = "\n"
      (0..@bounds[1] - 1).each do |y|
        (0..@bounds[0] - 1).each do |x|
          str += @positions.fetch([x, y], ".").to_s
        end
        str += "\n"
      end

      str
    end

    def tick
      @robots.each { |r| r.tick }
      @positions = positions()
      self
    end

    def ticks(times)
      @robots.each { |r| r.ticks(100) }
      @positions = positions()
      self
    end

    def factor
      @robots.map { |r| r.quadrant }
        .filter { |r| !r.nil? }
        .group_by(&:itself)
        .transform_values(&:size)
        .values.reduce(&:*)
    end

    def positions
      @robots.reduce(Hash.new { |h, k| h[k] = 0 }) do |acc, robot|
        acc[robot.p] += 1
        acc
      end
    end

    def unique_position?
      @positions.values.max == 1
    end
  end

  class Robot
    attr_reader :p

    def initialize(line, bounds)
      @p, @v = line.split(" ").map { |s| s.scan(/-?\d+/).map(&:to_i) }
      @bounds = bounds
    end

    def tick
      @p = @p.zip(@v).map(&:sum).zip(@bounds).map { |(a, b)| a % b }
    end

    def ticks(times)
      @p = @v.map { |v| v * times }.zip(@p).map(&:sum).zip(@bounds).map { |(a, b)| a % b }
    end

    def quadrant
      return 1 if @p[0] < @bounds[0] / 2 and @p[1] < @bounds[1] / 2
      return 2 if @p[0] > @bounds[0] / 2 and @p[1] < @bounds[1] / 2
      return 3 if @p[0] < @bounds[0] / 2 and @p[1] > @bounds[1] / 2
      return 4 if @p[0] > @bounds[0] / 2 and @p[1] > @bounds[1] / 2
      return nil
    end
  end
end
