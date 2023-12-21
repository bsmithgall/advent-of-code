defmodule Grid do
  defstruct w: 0, h: 0, points: %{}, coords: MapSet.new()

  def new(), do: %__MODULE__{}

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

  def extent(%__MODULE__{} = grid), do: {grid.w, grid.h}
  def x_min(%__MODULE__{} = grid), do: grid.coords |> Enum.map(&elem(&1, 0)) |> Enum.min()
  def x_extent(%__MODULE__{} = grid), do: grid.coords |> Enum.map(&elem(&1, 0)) |> Enum.min_max()
  def x_extent_r(%__MODULE__{} = grid), do: x_extent(grid) |> then(fn {s, e} -> s..e end)
  def y_min(%__MODULE__{} = grid), do: grid.coords |> Enum.map(&elem(&1, 1)) |> Enum.min()
  def y_extent(%__MODULE__{} = grid), do: grid.coords |> Enum.map(&elem(&1, 1)) |> Enum.min_max()

  def y_extent_r(%__MODULE__{} = grid), do: y_extent(grid) |> then(fn {s, e} -> s..e end)

  def get(%__MODULE__{} = grid, coord, default \\ nil), do: Map.get(grid.points, coord, default)

  def infinite_get(%__MODULE__{} = grid, {x, y}) do
    get(grid, {infinite_x(grid, x), infinite_y(grid, y)})
  end

  def member?(%__MODULE__{} = grid, coord), do: MapSet.member?(grid.coords, coord)

  def put(%__MODULE__{} = grid, coord, value) do
    Map.merge(grid, %{
      points: Map.put(grid.points, coord, value),
      coords: MapSet.put(grid.coords, coord)
    })
  end

  def find(%__MODULE__{} = grid, value) do
    Map.filter(grid.points, fn {_, v} -> v == value end)
  end

  @doc """
  Returns coords [E, W, N, S], with anything outside the grid represented as nil
  """
  def get_direct_neighbor_coords(%__MODULE__{} = grid, coord) do
    get_direct_neighbor_coords(grid, coord, :all)
    |> Enum.map(fn {x, y} ->
      if x <= grid.w and y <= grid.h and x >= 0 and y >= 0, do: {x, y}, else: nil
    end)
  end

  def get_direct_neighbor_coords(_, {x, y}, :all) do
    [
      {x + 1, y},
      {x - 1, y},
      {x, y - 1},
      {x, y + 1}
    ]
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
  end

  def neighbors?(%__MODULE__{} = grid, coord) do
    get_neighbor_coords(grid, coord)
    |> MapSet.new()
    |> MapSet.intersection(grid.coords)
    |> MapSet.size() > 0
  end

  def at_col(%__MODULE__{} = grid, row_idx) do
    Map.filter(grid.points, fn {{x, _}, _} -> x == row_idx end)
    |> Enum.map(fn {{_, y}, v} -> {y, v} end)
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(&elem(&1, 1))
  end

  def at_row(%__MODULE__{} = grid, col_idx) do
    Map.filter(grid.points, fn {{_, y}, _} -> y == col_idx end)
    |> Enum.map(fn {{x, _}, v} -> {x, v} end)
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(&elem(&1, 1))
  end

  defp infinite_x(%__MODULE__{} = grid, x) do
    (rem(x, grid.w + 1) + grid.w + 1) |> rem(grid.w + 1)
  end

  defp infinite_y(%__MODULE__{} = grid, y) do
    (rem(y, grid.h + 1) + grid.h + 1) |> rem(grid.h + 1)
  end
end
