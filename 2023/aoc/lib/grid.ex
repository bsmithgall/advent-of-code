defmodule Grid do
  defstruct w: 0, h: 0, points: %{}, coords: MapSet

  def from_input(input) do
    from_input(input, & &1)
  end

  def from_input(input, map_fn) do
    lines = input |> String.trim() |> String.split("\n")

    points =
      lines
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, idy}, acc ->
        Map.merge(
          acc,
          row
          |> String.trim()
          |> String.graphemes()
          |> Enum.map(fn c -> map_fn.(c) end)
          |> Enum.with_index()
          |> Enum.filter(fn {val, _} -> !is_nil(val) end)
          |> Enum.reduce(%{}, fn {val, idx}, row_acc ->
            Map.merge(row_acc, %{{idx, idy} => val})
          end)
        )
      end)

    %__MODULE__{
      w: (lines |> hd() |> String.graphemes() |> length()) - 1,
      h: (lines |> length()) - 1,
      points: points,
      coords: points |> Map.keys() |> MapSet.new()
    }
  end

  def get_neighbor_coords(%__MODULE__{} = grid, {x, y}) do
    [
      {x + 1, y + 1},
      {x + 1, y - 1},
      {x + 1, y},
      {x - 1, y + 1},
      {x - 1, y - 1},
      {x - 1, y},
      {x, y + 1},
      {x, y - 1}
    ]
    |> Enum.filter(fn {x, y} -> x <= grid.w and y <= grid.h and x >= 0 and y >= 0 end)
    |> MapSet.new()
  end

  def neighbors?(%__MODULE__{} = grid, coord) do
    get_neighbor_coords(grid, coord) |> MapSet.intersection(grid.coords) |> MapSet.size() > 0
  end
end