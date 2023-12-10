defmodule Days.Day10 do
  @behaviour Days.Day

  @impl Days.Day
  def part_one(input) do
    Grid.from_input(input)
    |> find_enclosed_loop()
    |> elem(0)
    |> MapSet.size()
    |> Kernel./(2)
    |> floor()
  end

  @impl Days.Day
  @doc """
  Slightly modified scanline algorithm, see:
  https://web.cs.ucdavis.edu/~ma/ECS175_S00/Notes/0411_b.pdf
  for helpful diagrams
  """
  def part_two(input) do
    grid = Grid.from_input(input)
    {loop, {start_coord, start_value}} = find_enclosed_loop(grid)
    grid = Grid.put(grid, start_coord, start_value)

    Enum.reduce(0..grid.h, 0, fn y, acc ->
      Enum.reduce(0..grid.w, {acc, false}, fn x, {row_acc, inside?} ->
        v = Grid.get(grid, {x, y})
        in_loop = MapSet.member?(loop, {x, y})

        # scan across the line, flipping if we are inside or outside based on
        # encountering │ ┌ or ┐ characters
        inside? = if in_loop and flip?(v), do: not inside?, else: inside?

        # if we are inside and not in the pipe loop, we are contained, increment
        # by one
        if not in_loop and inside?, do: {row_acc + 1, inside?}, else: {row_acc, inside?}
      end)
      |> elem(0)
    end)
  end

  def find_enclosed_loop(%Grid{} = grid) do
    start = Map.filter(grid.points, fn {_k, v} -> v == "S" end) |> Map.keys() |> hd()

    first_neighbors =
      Grid.get_direct_neighbor_coords(grid, start)
      |> Enum.filter(&(!is_nil(&1)))
      |> Enum.filter(fn pt ->
        {l, r} = edges(grid, pt)
        l == start or r == start
      end)

    first_neighbor = hd(first_neighbors)

    start_char =
      Enum.reduce_while(~w[- | L J 7 F], "S", fn v, _ ->
        if edges(start, v) |> Tuple.to_list() |> Enum.sort() == first_neighbors |> Enum.sort(),
          do: {:halt, v},
          else: {:cont, v}
      end)

    {next_point(grid, MapSet.new([start]), start, first_neighbor, Grid.get(grid, first_neighbor)),
     {start, start_char}}
  end

  def next_point(_, %MapSet{} = visited, _, _, "S"), do: visited

  def next_point(%Grid{} = grid, %MapSet{} = visited, from, point, v) do
    visited = MapSet.put(visited, point)
    {l, r} = edges(point, v)

    if l == from,
      do: next_point(grid, visited, point, r, Grid.get(grid, r)),
      else: next_point(grid, visited, point, l, Grid.get(grid, l))
  end

  def edges(%Grid{} = grid, point), do: edges(point, Grid.get(grid, point))
  def edges({x, y}, "|"), do: {{x, y + 1}, {x, y - 1}}
  def edges({x, y}, "-"), do: {{x + 1, y}, {x - 1, y}}
  def edges({x, y}, "L"), do: {{x + 1, y}, {x, y - 1}}
  def edges({x, y}, "J"), do: {{x - 1, y}, {x, y - 1}}
  def edges({x, y}, "7"), do: {{x - 1, y}, {x, y + 1}}
  def edges({x, y}, "F"), do: {{x + 1, y}, {x, y + 1}}
  def edges(_, _), do: {{}, {}}

  def flip?(v), do: v == "|" or v == "7" or v == "F"
end
