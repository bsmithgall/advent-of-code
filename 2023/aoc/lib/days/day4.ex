defmodule Days.Day4 do
  @behaviour Days.Day

  @impl Days.Day
  def part_one(input) do
    input
    |> winning_counts()
    |> Enum.map(fn ct ->
      case ct do
        0 -> 0
        1 -> 1
        n when n > 1 -> :math.pow(2, n - 1) |> trunc()
      end
    end)
    |> Enum.sum()
  end

  @impl Days.Day
  def part_two(input) do
    counts = input |> winning_counts()

    counts_map = 1..length(counts) |> Enum.reduce(%{}, fn i, acc -> Map.merge(acc, %{i => 1}) end)

    counts
    |> Enum.with_index(1)
    |> Enum.reduce(counts_map, &add_cards/2)
    |> Map.values()
    |> Enum.sum()
  end

  def strip_card_number(line) do
    case Regex.run(~r/Card \d+:/, line) do
      [match] -> line |> String.replace(match, "")
      _ -> line
    end
  end

  def winning_counts(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&strip_card_number/1)
    |> Enum.map(&String.split(&1, "|"))
    |> Enum.map(fn parts ->
      [l, r] =
        parts
        |> Enum.map(&String.trim/1)
        |> Enum.map(&String.split(&1, ~r/\s+/))
        |> Enum.map(&MapSet.new/1)

      MapSet.intersection(l, r) |> MapSet.size()
    end)
  end

  def add_cards({0, _}, acc), do: acc

  def add_cards({ct, card_number}, acc) do
    apply_times = Map.get(acc, card_number)

    (card_number + 1)..(card_number + ct)
    |> Enum.reduce(acc, fn c, acc ->
      if c <= map_size(acc) do
        {_, acc} = Map.get_and_update(acc, c, fn v -> {v, v + apply_times} end)
        acc
      else
        acc
      end
    end)
  end
end
