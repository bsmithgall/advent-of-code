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
        _ -> {"Could not find module for day #{day}.", :na}
      end

    IO.puts("Part 1 Result \"#{r1}\", Took #{t1 / 1_000_000}ms")
    IO.puts("Part 2 Result \"#{r2}\", Took #{t2 / 1_000_000}ms")
  end

  defp input(day) do
    [:code.priv_dir(:aoc), "inputs/day-#{day}.txt"] |> Path.join() |> File.read!()
  end
end