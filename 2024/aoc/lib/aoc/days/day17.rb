require_relative "../day"

module Aoc::Day
  class Day17
    include Aoc::Day

    def initialize(input)
      registers, program = input.strip.split("\n\n")
      @a, @b, @c = registers.split("\n").map { |s| s.scan(/\d+/).map(&:to_i) }.map(&:first)
      @program = program.sub("Program: ", "").split(",").map(&:to_i)
    end

    def part1
      ThreeBitComputer.new(@a, @b, @c, @program).run_til_halt.output.join(",")
    end

    def part2
      q = [[0, @program.length - 1]]

      while !q.empty?
        a, d = q.shift
        (0..7).each do |i|
          next_a = (a << 3) + i
          out = ThreeBitComputer.new(next_a, @b, @c, @program).run_til_halt.output

          next if out.first != @program[d]
          return next_a if d == 0
          q.push([next_a, d - 1])
        end
      end
    end
  end

  class ThreeBitComputer
    attr_reader :output

    def initialize(a, b, c, program)
      @a, @b, @c = a, b, c
      @memory = program

      @pointer = 0
      @output = []
    end

    def run_til_halt
      run while @pointer < @memory.length
      self
    end

    def run
      opcode = @memory[@pointer]

      if opcode == 0
        adv
      elsif opcode == 1
        bxl
      elsif opcode == 2
        bst
      elsif opcode == 3
        jnz
      elsif opcode == 4
        bxc
      elsif opcode == 5
        out
      elsif opcode == 6
        bdv
      elsif opcode == 7
        cdv
      end
    end

    def adv
      @a = @a / (2 ** combo_operand)
      @pointer += 2
    end

    def bxl
      @b = @b ^ literal_operand
      @pointer += 2
    end

    def bst
      @b = combo_operand % 8
      @pointer += 2
    end

    def jnz
      @pointer = (@a == 0 ? @pointer + 2 : literal_operand)
    end

    def bxc
      @b = @b ^ @c
      @pointer += 2
    end

    def out
      @output.push(combo_operand % 8)
      @pointer += 2
    end

    def bdv
      @b = @a / (2 ** combo_operand)
      @pointer += 2
    end

    def cdv
      @c = @a / (2 ** combo_operand)
      @pointer += 2
    end

    def literal_operand
      @memory[@pointer + 1]
    end

    def combo_operand
      case @memory[@pointer + 1]
      when 0..3
        @memory[@pointer + 1]
      when 4
        @a
      when 5
        @b
      when 6
        @c
      end
    end
  end
end
