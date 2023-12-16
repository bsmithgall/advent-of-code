defmodule Days.Day16 do
  require IEx
  @behaviour Days.Day

  @impl Days.Day
  def part_one(input) do
    Grid.from_input(input)
    |> count_energized({{0, 0}, :e})
  end

  @impl Days.Day
  def part_two(input) do
    grid = Grid.from_input(input)

    for y <- 0..(grid.h - 1),
        x <- 0..(grid.w - 1),
        x == 0 or y == 0 or x == grid.w - 1 or y == grid.h - 1 do
      {x, y}
    end
    |> Enum.flat_map(&generate_start(&1, grid.h - 1))
    |> Task.async_stream(&count_energized(grid, &1))
    |> Stream.map(&elem(&1, 1))
    |> Enum.max()
  end

  def generate_start({0, 0}, _), do: [{{0, 0}, :s}, {{0, 0}, :e}]
  def generate_start({x, x}, x), do: [{{x, x}, :n}, {{x, x}, :w}]
  def generate_start({0, x}, x), do: [{{0, x}, :n}, {{0, x}, :e}]
  def generate_start({x, 0}, x), do: [{{x, 0}, :s}, {{x, 0}, :w}]
  def generate_start({0, y}, _), do: [{{0, y}, :e}]
  def generate_start({x, 0}, _), do: [{{x, 0}, :s}]
  def generate_start({x, y}, x), do: [{{x, y}, :n}]
  def generate_start({x, y}, y), do: [{{x, y}, :w}]

  def count_energized(grid, start) do
    bfs(%{}, grid, [start], [])
    |> Map.filter(fn {{coords, _}, _} -> MapSet.member?(grid.coords, coords) end)
    |> Enum.map(fn {{coords, _}, _} -> coords end)
    |> Enum.uniq()
    |> Enum.count()
  end

  def bfs(%{} = visited, %Grid{}, [], []), do: visited

  def bfs(%{} = visisted, %Grid{} = grid, [], neighbors) do
    bfs(visisted, grid, neighbors, [])
  end

  def bfs(%{} = visited, %Grid{} = grid, [head | tail], neighbors)
      when is_map_key(visited, head) do
    bfs(visited, grid, tail, neighbors)
  end

  def bfs(%{} = visited, %Grid{} = grid, [head | tail], neighbors) do
    Map.put(visited, head, 1) |> bfs(grid, tail, get_neighbors(grid, head) ++ neighbors)
  end

  def get_neighbors(_, []), do: []

  def get_neighbors(%Grid{} = grid, {{x, y} = coord, :n}) do
    case Grid.get(grid, coord) do
      "|" -> [{{x, y - 1}, :n}]
      "." -> [{{x, y - 1}, :n}]
      "-" -> [{{x - 1, y}, :w}, {{x + 1, y}, :e}]
      "\\" -> [{{x - 1, y}, :w}]
      "/" -> [{{x + 1, y}, :e}]
      nil -> []
    end
  end

  def get_neighbors(%Grid{} = grid, {{x, y} = coord, :s}) do
    case Grid.get(grid, coord) do
      "|" -> [{{x, y + 1}, :s}]
      "." -> [{{x, y + 1}, :s}]
      "-" -> [{{x - 1, y}, :w}, {{x + 1, y}, :e}]
      "\\" -> [{{x + 1, y}, :e}]
      "/" -> [{{x - 1, y}, :w}]
      nil -> []
    end
  end

  def get_neighbors(%Grid{} = grid, {{x, y} = coord, :e}) do
    case Grid.get(grid, coord) do
      "|" -> [{{x, y - 1}, :n}, {{x, y + 1}, :s}]
      "." -> [{{x + 1, y}, :e}]
      "-" -> [{{x + 1, y}, :e}]
      "\\" -> [{{x, y + 1}, :s}]
      "/" -> [{{x, y - 1}, :n}]
      nil -> []
    end
  end

  def get_neighbors(%Grid{} = grid, {{x, y} = coord, :w}) do
    case Grid.get(grid, coord) do
      "|" -> [{{x, y - 1}, :n}, {{x, y + 1}, :s}]
      "." -> [{{x - 1, y}, :w}]
      "-" -> [{{x - 1, y}, :w}]
      "\\" -> [{{x, y - 1}, :n}]
      "/" -> [{{x, y + 1}, :s}]
      nil -> []
    end
  end
end
