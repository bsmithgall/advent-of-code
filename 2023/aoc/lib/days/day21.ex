defmodule Days.Day21 do
  @behaviour Days.Day

  @impl Days.Day
  def part_one(input, steps \\ 64) do
    grid = Grid.from_input(input)
    start = Grid.find(grid, "S") |> Map.keys()

    step_to(grid, start, steps) |> Map.get(steps)
  end

  @impl Days.Day
  def part_two(input) do
    grid = Grid.from_input(input)
    size = grid.w + 1

    start = Grid.find(grid, "S") |> Map.keys()

    offset = rem(26_501_365, size)
    seq = step_to(grid, start, offset + size * 2)

    one = Map.get(seq, offset)
    two = Map.get(seq, offset + size)
    three = Map.get(seq, offset + size * 2)

    c = one

    a_plus_b = two - c
    four_a_times_two_b = three - c

    two_a = four_a_times_two_b - 2 * a_plus_b
    a = (two_a / 2) |> trunc()
    b = (a_plus_b - a) |> trunc()

    quad(a, b, c, 202_300)
  end

  def step_to(%Grid{} = grid, start, goal) do
    step_to(grid, start, %{}, 0, goal)
  end

  def step_to(_, _, count_map, goal, goal), do: count_map

  def step_to(%Grid{} = grid, current, count_map, cur_step, goal) do
    next = step(grid, current)
    count_map = Map.put(count_map, cur_step + 1, length(next))
    step_to(grid, next, count_map, cur_step + 1, goal)
  end

  def step(%Grid{} = grid, current) do
    current
    |> Enum.flat_map(fn pt -> Grid.get_direct_neighbor_coords(grid, pt, :all) end)
    |> Enum.map(fn coord -> {coord, Grid.infinite_get(grid, coord)} end)
    |> Enum.filter(fn {_, v} -> v != "#" end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.uniq()
  end

  def quad(a, b, c, x), do: a * (x * x) + b * x + c
end
