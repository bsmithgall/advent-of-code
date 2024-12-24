require_relative "../day"
require "pry"

module Aoc::Day
  class Day24
    include Aoc::Day

    def initialize(input)
      vals, instructs = input.strip.split("\n\n")
      re = /(.{3}) (.+) (.{3}) -> (.{3})/

      @vals = vals.split("\n").map { |l| l.split(": ") }.map { |(x, i)| [x, i.to_i] }.to_h
      @instructs = instructs.split("\n").flat_map { |s| s.scan(re) }.map { |r| Instruct.new(*r) }

      @instructs.each do |i|
        @vals[i.l] = nil unless @vals.include?(i.l)
        @vals[i.r] = nil unless @vals.include?(i.r)
        @vals[i.out] = nil unless @vals.include?(i.out)
      end
    end

    def part1
      follow("z", simulate)
    end

    # https://www.reddit.com/r/adventofcode/comments/1hla5ql/2024_day_24_part_2_a_guide_on_the_idea_behind_the/
    # never would have figured this out otherwise
    def part2
      nxz = @instructs.filter { |v| v.endZXor? }
      xnz = @instructs.filter { |v| v.notEndZAndNotXY? }

      xnz.each do |i|
        up = nxz.find { |n| n.out == findFirstZUsingOutput(i.out) }
        tmp = i.out
        i.out = up.out
        up.out = tmp
      end

      followX = follow("x")
      followY = follow("y")
      followZ = follow("z", simulate)

      falseTrailer = ((followX + followY) ^ followZ).to_s(2).reverse.index("1").to_s

      (nxz + xnz + @instructs.filter { |i| i.l.end_with?(falseTrailer) and i.r.end_with?(falseTrailer) })
        .map { |i| i.out }
        .sort
        .join(",")
    end

    def simulate(vals = Hash.new.merge(@vals))
      zcount = vals.reduce(0) { |acc, (k, _)| k.start_with?("z") ? acc + 1 : acc }
      while zcount > 0
        @instructs.each do |i|
          next unless i.instructable?(vals)
          vals[i.out] = i.eval(vals)
          zcount -= 1 if i.z?
        end
      end

      vals
    end

    def follow(c, vals = @vals)
      vals.filter { |(k, _)| k.start_with?(c) }.to_a.sort.map { |i| i[1] }.join("").reverse.to_i(2)
    end

    def findFirstZUsingOutput(out)
      matches = @instructs.filter { |i| i.l == out || i.r == out }
      maybeMatch = matches.find { |m| m.z? }

      return zMinusOne(maybeMatch.out) unless maybeMatch.nil?

      findFirstZUsingOutput(matches[0].out)
    end

    def zMinusOne(out)
      return out unless out.start_with?("z")

      val = out.match(/z(\d{2})/)[1].to_i - 1
      "z#{val.to_s.rjust(2, "0")}"
    end
  end

  class Instruct
    attr_accessor :l, :op, :r, :out

    def initialize(l, op, r, out)
      @l = l
      @op = op
      @r = r
      @out = out
    end

    def instructable?(vals)
      vals[self.out].nil? and (!vals[self.l].nil? and !vals[self.r].nil?)
    end

    def z?
      self.out.start_with?("z")
    end

    def eval(vals)
      case self.op
      when "AND"
        vals[self.l] & vals[self.r]
      when "OR"
        vals[self.l] | vals[self.r]
      when "XOR"
        vals[self.l] ^ vals[self.r]
      end
    end

    def endZXor?
      z? \
        and self.out != "z45" \
        and self.op != "XOR"
    end

    def notEndZAndNotXY?
      !self.l.start_with?("x", "y") \
        and !self.r.start_with?("x", "y") \
        and !z? \
        and self.op == "XOR"
    end
  end
end
