defmodule Days.Day3 do
  @behaviour Days.Day

  @impl Days.Day
  def part_one(input) do
    symbol_grid =
      Grid.from_input(input, fn v ->
        case Integer.parse(v) do
          {_n, _} -> nil
          :error when v == "." -> nil
          :error -> v
        end
      end)

    np = get_number_positions(input)

    np
    |> Map.filter(fn {coords, _} ->
      Enum.any?(coords, fn c -> Grid.neighbors?(symbol_grid, c) end)
    end)
    |> Map.values()
    |> Enum.sum()
  end

  @impl Days.Day
  def part_two(input) do
    gear_candidate_grid =
      Grid.from_input(input, fn v ->
        case Integer.parse(v) do
          {_n, _} -> nil
          :error when v == "*" -> v
          :error -> nil
        end
      end)

    np = get_number_positions(input)
    np_sets = np |> Map.keys() |> Enum.map(&MapSet.new/1)

    gear_candidate_grid.points
    |> Map.keys()
    |> Enum.map(fn point ->
      neighbors = Grid.get_neighbor_coords(gear_candidate_grid, point) |> MapSet.new()
      joint = Enum.filter(np_sets, fn np -> !MapSet.disjoint?(np, neighbors) end)

      if length(joint) == 2 do
        Enum.map(joint, fn p -> Map.get(np, MapSet.to_list(p)) end) |> Enum.product()
      else
        nil
      end
    end)
    |> Enum.filter(&(!is_nil(&1)))
    |> Enum.sum()
  end

  def get_number_positions(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, idy}, acc ->
      Map.merge(
        acc,
        parse_row(row, idy)
      )
    end)
  end

  def parse_row(row, idy) do
    row
    |> String.trim()
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.chunk_by(fn {r, _} -> Utils.intable?(r) end)
    |> Enum.reduce(%{}, fn chunk, acc ->
      {num, indexes} =
        chunk
        |> Enum.map(fn {r, idx} -> {Utils.try_int(r), idx} end)
        |> Enum.unzip()

      if is_integer(hd(num)) do
        Map.merge(acc, %{Enum.map(indexes, fn idx -> {idx, idy} end) => Integer.undigits(num)})
      else
        acc
      end
    end)
  end
end
