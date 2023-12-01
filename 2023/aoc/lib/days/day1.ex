defmodule Days.Day1 do
  @behaviour Days.Day

  @impl Days.Day
  def part_one(input) do
    input |> String.split("\n") |> Enum.map(&process_line/1) |> Enum.sum()
  end

  @impl Days.Day
  def part_two(input) do
    input |> String.split("\n") |> Enum.map(&process_line_regex/1) |> Enum.sum()
  end

  def process_line(""), do: 0

  def process_line(line) do
    ints =
      line
      |> String.graphemes()
      |> Enum.reduce([], fn char, acc ->
        case Integer.parse(char) do
          :error -> acc
          {x, _} -> [x | acc]
        end
      end)
      |> Enum.reverse()

    Integer.undigits([hd(ints), List.last(ints)])
  end

  def process_line_regex(""), do: 0

  def process_line_regex(line) do
    ints =
      Regex.scan(~r/(?=(one|two|three|four|five|six|seven|eight|nine|\d))/, line)
      |> List.flatten()
      |> Enum.filter(&(&1 != ""))
      |> Enum.map(fn match ->
        case match do
          "one" -> 1
          "two" -> 2
          "three" -> 3
          "four" -> 4
          "five" -> 5
          "six" -> 6
          "seven" -> 7
          "eight" -> 8
          "nine" -> 9
          _ -> String.to_integer(match)
        end
      end)

    Integer.undigits([hd(ints), List.last(ints)])
  end
end
