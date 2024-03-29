defmodule AOC do
  @moduledoc """
  Documentation for `Aoc`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Aoc.hello()
      :world

  """
  def main(day) do
    {{t1, r1}, {t2, r2}} =
      case day do
        1 -> Days.Day.exec(Days.Day1, input(day))
        2 -> Days.Day.exec(Days.Day2, input(day))
        3 -> Days.Day.exec(Days.Day3, input(day))
        4 -> Days.Day.exec(Days.Day4, input(day))
        5 -> Days.Day.exec(Days.Day5, input(day))
        6 -> Days.Day.exec(Days.Day6, input(day))
        7 -> Days.Day.exec(Days.Day7, input(day))
        8 -> Days.Day.exec(Days.Day8, input(day))
        9 -> Days.Day.exec(Days.Day9, input(day))
        10 -> Days.Day.exec(Days.Day10, input(day))
        11 -> Days.Day.exec(Days.Day11, input(day))
        12 -> Days.Day.exec(Days.Day12, input(day))
        13 -> Days.Day.exec(Days.Day13, input(day))
        14 -> Days.Day.exec(Days.Day14, input(day))
        15 -> Days.Day.exec(Days.Day15, input(day))
        16 -> Days.Day.exec(Days.Day16, input(day))
        17 -> Days.Day.exec(Days.Day17, input(day))
        18 -> Days.Day.exec(Days.Day18, input(day))
        19 -> Days.Day.exec(Days.Day19, input(day))
        20 -> Days.Day.exec(Days.Day20, input(day))
        21 -> Days.Day.exec(Days.Day21, input(day))
        22 -> Days.Day.exec(Days.Day22, input(day))
        23 -> Days.Day.exec(Days.Day23, input(day))
        24 -> Days.Day.exec(Days.Day24, input(day))
        25 -> Days.Day.exec(Days.Day25, input(day))
        _ -> {"Could not find module for day #{day}.", :na}
      end

    IO.puts("Part 1 Result \"#{r1}\", Took #{t1 / 1_000}ms")
    IO.puts("Part 2 Result \"#{r2}\", Took #{t2 / 1_000}ms")
  end

  defp input(day) do
    [:code.priv_dir(:aoc), "inputs/day-#{day}.txt"] |> Path.join() |> File.read!()
  end
end
