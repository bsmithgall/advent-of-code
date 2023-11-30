defmodule Mix.Tasks.Aoc do
  use Mix.Task

  @impl Mix.Task
  def run(args) do
    AOC.main(String.to_integer(Enum.at(args, 0)))
  end
end
