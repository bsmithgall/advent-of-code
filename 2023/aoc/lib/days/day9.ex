defmodule Days.Day9 do
  @behaviour Days.Day

  @impl Days.Day
  def part_one(input) do
    rows =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.map(fn row -> String.split(row, ~r/\s+/) |> Enum.map(&Utils.try_int/1) end)

    Enum.map(rows, fn row -> List.last(row) + generate_sequence(row) end) |> Enum.sum()
  end

  @impl Days.Day
  def part_two(input) do
    rows =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.map(fn row -> String.split(row, ~r/\s+/) |> Enum.map(&Utils.try_int/1) end)

    Enum.map(rows, &Enum.reverse/1)
    |> Enum.map(fn row -> List.last(row) + generate_sequence(row) end)
    |> Enum.sum()
  end

  def generate_sequence(sequence) do
    next =
      0..(length(sequence) - 2)
      |> Enum.reduce([], fn idx, acc ->
        [Enum.at(sequence, idx + 1) - Enum.at(sequence, idx) | acc]
      end)
      |> Enum.reverse()

    if Enum.all?(next, &(&1 == 0)), do: 0, else: List.last(next) + generate_sequence(next)
  end
end
