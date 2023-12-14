defmodule Days.Day14 do
  @behaviour Days.Day

  @impl Days.Day
  def part_one(input) do
    Grid.from_input(input)
    |> then(fn grid -> roll(grid, &furthest_north/3, 0..grid.h) end)
    |> sum()
  end

  @impl Days.Day
  def part_two(input) do
    {first_saw, cycle_len, _step, _grid} = Grid.from_input(input) |> cycle_til_loop()
    needed_cycles = first_saw + rem(1_000_000_000 - first_saw, cycle_len)

    Process.get(needed_cycles) |> Grid.from_input() |> sum()
  end

  def sum(%Grid{} = grid) do
    grid.points
    |> Enum.reduce(0, fn {{_, y}, v}, acc ->
      if v == "O", do: acc + (grid.h - y) + 1, else: acc
    end)
  end

  def cycle_til_loop(%Grid{} = grid) do
    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while({1, grid}, fn _, {i, acc} ->
      if rem(i, 20) == 0, do: dbg(i)

      cycled = cycle(acc)
      prev_cycle? = Process.get(inspect(cycled))

      if is_nil(prev_cycle?) do
        Process.put(inspect(cycled), i)
        Process.put(i, inspect(cycled))
        {:cont, {i + 1, cycled}}
      else
        {:halt, {prev_cycle?, i - prev_cycle?, i, cycled}}
      end
    end)
  end

  def cycle(%Grid{} = grid) do
    grid
    |> roll(&furthest_north/3, 0..grid.h)
    |> roll(&furthest_west/3, 0..grid.w)
    |> roll(&furthest_south/3, grid.h..0)
    |> roll(&furthest_east/3, grid.w..0)
  end

  def roll(%Grid{} = grid, roll_func, range) do
    Enum.reduce(range, grid, fn y, acc ->
      Enum.reduce(range, acc, fn x, row_acc ->
        value = Grid.get(row_acc, {x, y})

        if value == "O" do
          {new_x, new_y} = roll_func.(row_acc, {x, y}, value)
          Grid.put(row_acc, {x, y}, ".") |> Grid.put({new_x, new_y}, value)
        else
          row_acc
        end
      end)
    end)
  end

  def furthest_north(_, {x, 0}, _), do: {x, 0}
  def furthest_north(_, {x, y}, "."), do: {x, y}
  def furthest_north(_, {x, y}, "#"), do: {x, y}

  def furthest_north(%Grid{} = grid, {x, y}, "O") do
    Enum.reduce_while((y - 1)..0, y - 1, fn idy, acc ->
      if Grid.get(grid, {x, idy}) == ".", do: {:cont, acc - 1}, else: {:halt, acc}
    end)
    |> then(&(&1 + 1))
    |> then(fn y -> {x, y} end)
  end

  def furthest_east(%Grid{} = grid, {x, y}, _) when grid.w == x, do: {x, y}
  def furthest_east(_, {x, y}, "."), do: {x, y}
  def furthest_east(_, {x, y}, "#"), do: {x, y}

  def furthest_east(%Grid{} = grid, {x, y}, "O") do
    Enum.reduce_while((x + 1)..grid.w, x + 1, fn idx, acc ->
      if Grid.get(grid, {idx, y}) == ".", do: {:cont, acc + 1}, else: {:halt, acc}
    end)
    |> then(&(&1 - 1))
    |> then(fn x -> {x, y} end)
  end

  def furthest_west(_, {0, y}, _), do: {0, y}
  def furthest_west(_, {x, y}, "."), do: {x, y}
  def furthest_west(_, {x, y}, "#"), do: {x, y}

  def furthest_west(%Grid{} = grid, {x, y}, "O") do
    Enum.reduce_while((x - 1)..0, x - 1, fn idx, acc ->
      if Grid.get(grid, {idx, y}) == ".", do: {:cont, acc - 1}, else: {:halt, acc}
    end)
    |> then(&(&1 + 1))
    |> then(fn x -> {x, y} end)
  end

  def furthest_south(%Grid{} = grid, {x, y}, _) when grid.h == y, do: {x, y}
  def furthest_south(_, {x, y}, "."), do: {x, y}
  def furthest_south(_, {x, y}, "#"), do: {x, y}

  def furthest_south(%Grid{} = grid, {x, y}, "O") do
    Enum.reduce_while((y + 1)..grid.h, y + 1, fn idy, acc ->
      if Grid.get(grid, {x, idy}) == ".", do: {:cont, acc + 1}, else: {:halt, acc}
    end)
    |> then(&(&1 - 1))
    |> then(fn y -> {x, y} end)
  end
end
