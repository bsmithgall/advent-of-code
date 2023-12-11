defmodule Days.Day11 do
  @behaviour Days.Day

  @impl Days.Day
  def part_one(input) do
    Grid.from_input(input, &if(&1 == ".", do: nil, else: &1)) |> expand() |> calculate()
  end

  @impl Days.Day
  def part_two(input, scaling_factor \\ 1_000_000) do
    Grid.from_input(input, &if(&1 == ".", do: nil, else: &1))
    # replace one row with scaling_factor rows (but don't double count!)
    |> expand(scaling_factor - 1)
    |> calculate()
  end

  def expand(%Grid{} = grid, scaling_factor \\ 1) do
    in_rows = grid.coords |> Enum.map(&elem(&1, 0)) |> Enum.frequencies() |> Map.keys()
    rows_to_expand = 0..grid.w |> Enum.filter(&(not Enum.member?(in_rows, &1)))

    in_cols = grid.coords |> Enum.map(&elem(&1, 1)) |> Enum.frequencies() |> Map.keys()
    cols_to_expand = 0..grid.h |> Enum.filter(&(not Enum.member?(in_cols, &1)))

    Enum.map(grid.coords, fn {x, y} ->
      {
        x + Enum.count(rows_to_expand, &(&1 < x)) * scaling_factor,
        y + Enum.count(cols_to_expand, &(&1 < y)) * scaling_factor
      }
    end)
  end

  def calculate(expanded) do
    for {x1, y1} = l <- expanded,
        {x2, y2} = r <- expanded,
        l != r do
      # manhattan distance: https://en.wikipedia.org/wiki/Taxicab_geometry
      abs(x1 - x2) + abs(y1 - y2)
    end
    |> Enum.sum()
    |> Kernel./(2)
    |> trunc()
  end
end
