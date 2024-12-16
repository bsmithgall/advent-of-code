require_relative "../day"
require_relative "../grid"

DIRS = { "<" => :w, ">" => :e, "^" => :n, "v" => :s }

module Aoc::Day
  class Day15
    include Aoc::Day

    def initialize(input)
      @input = input
    end

    def part1
      LanternBot.new(@input).move_all.gps
    end

    def part2
      DoubleLanternBot.new(@input).move_all.gps
    end
  end

  class DoubleLanternBot < Aoc::Grid
    attr_reader :moves

    DOUBLES = {
      "#" => "##", "." => "..", "O" => "[]", "@" => "@.", "\n" => "\n",
    }

    def initialize(input)
      area, moves = input.strip.split("\n\n")

      super(area.chars.map { |c| DOUBLES[c] }.join)

      @moves = moves.gsub("\n", "").chars.map { |c| DIRS[c] }
      @pos = find("@")
      @points[@pos[1]][@pos[0]] = "."
      @boxes = Set.new(find_all("["))
    end

    def move_all
      @moves.each(&method(:move))
      self
    end

    def move(move)
      can_push, would_push = pushables(@pos, move)

      if can_push
        @boxes.delete_if { |b| would_push.include?(b) }
        would_push.map { |p| step(p, move) }.each { |b| @boxes.add(b) }
        @pos = step(@pos, move)
      end

      self
    end

    def pushables(pos, dir, moved = Set.new)
      next_pos = step(pos, dir)
      return [false, moved] if at(*next_pos) == "#"
      return [true, moved] if !box?(next_pos) and moved.empty?

      (-1..0).each do |offset|
        l = step_by(next_pos, [offset, 0])
        r = step_by(l, [1, 0])
        if @boxes.include?(l)
          return [true, moved] if moved.include?(l)

          moved.add(l)

          l_can, l_would = pushables(l, dir, moved)
          r_can, r_would = pushables(r, dir, moved)

          if l_can and r_can
            return [true, moved + l_would + r_would]
          else
            return [false, moved]
          end
        end
      end

      [true, moved]
    end

    def gps
      @boxes.map { |(x, y)| y * 100 + x }.sum
    end

    def box?(pos)
      @boxes.include?(pos) || @boxes.include?(step_by(pos, [-1, 0]))
    end

    def inspect
      str = "\n"
      rows.each do |y|
        cols.each do |x|
          if @boxes.include?([x, y])
            str += "["
          elsif @boxes.include?([x - 1, y])
            str += "]"
          elsif at(x, y) == "#"
            str += "#"
          elsif [x, y] == @pos
            str += "@"
          else
            str += "."
          end
        end
        str += "\n"
      end
      str
    end
  end

  class LanternBot < Aoc::Grid
    attr_reader :moves

    def initialize(input)
      area, moves = input.strip.split("\n\n")
      super(area)

      @moves = moves.gsub("\n", "").chars.map { |c| DIRS[c] }
      @pos = find("@")
      @points[@pos[1]][@pos[0]] = "."
    end

    def move_all
      @moves.each(&method(:move))
      self
    end

    def move(move)
      to_push = find_all_to_push(move)

      return self if to_push.nil?

      to_push.map { |p| [p, step(p, move)] }.each do |(x1, y1), (x2, y2)|
        @points[y1][x1] = "."
        @points[y2][x2] = "O"
      end

      @pos = step(@pos, move)
      self
    end

    def find_all_to_push(dir)
      to_push = []

      next_pos = step(@pos, dir)
      at_pos = at(*next_pos)

      while at_pos == "O"
        to_push.prepend(next_pos)
        next_pos = step(next_pos, dir)
        at_pos = at(*next_pos)
      end

      return at_pos == "#" ? nil : to_push
    end

    def gps
      find_all("O").map { |(x, y)| y * 100 + x }.sum
    end
  end
end
