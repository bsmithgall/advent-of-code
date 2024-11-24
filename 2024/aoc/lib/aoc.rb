# frozen_string_literal: true

require_relative "aoc/version"
require_relative "aoc/day"

module Aoc
  class Error < StandardError; end

  # Your code goes here...
  #
  def self.find_input(day)
    root = File.join(File.expand_path(File.dirname(__FILE__)), "..")
    path = File.join(root, "inputs/day-#{day}.txt")
    if !File.exist?(path) 
      raise "No file found for day #{day}! Try 'rake touch #{day}'"
    end
    File.read(path)
  end
end
