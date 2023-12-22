defmodule Days.Day22 do
  @behaviour Days.Day

  defstruct id: -1, x: 0..0, y: 0..0, z: 0..0

  @impl Days.Day
  def part_one(input) do
    {grid, blocks} = parse_input(input) |> fall()

    blocks
    |> Enum.reduce(0, fn block, acc ->
      disintegrated_blocks = List.delete(blocks, block)

      disintegrated_grid =
        for x <- block.x, y <- block.y, z <- block.z, reduce: grid do
          disintegrated -> Grid.delete(disintegrated, {x, y, z})
        end

      {fallen, _} = fall(disintegrated_grid, disintegrated_blocks)

      if MapSet.equal?(fallen.coords, disintegrated_grid.coords), do: acc + 1, else: acc
    end)
  end

  @impl Days.Day
  def part_two(input) do
    {grid, blocks} = parse_input(input) |> fall()

    blocks
    |> Enum.reduce(0, fn block, acc ->
      disintegrated_blocks = List.delete(blocks, block)

      disintegrated_grid =
        for x <- block.x, y <- block.y, z <- block.z, reduce: grid do
          disintegrated -> Grid.delete(disintegrated, {x, y, z})
        end

      {_, fallen_blocks} = fall(disintegrated_grid, disintegrated_blocks)

      Enum.zip(fallen_blocks, disintegrated_blocks)
      |> Enum.reduce(acc, fn {f, d}, block_acc ->
        if(f.x == d.x and f.y == d.y and f.z == d.z, do: block_acc, else: block_acc + 1)
      end)
    end)
  end

  def parse_input(input) do
    blocks =
      input
      |> String.split("\n", trim: true)
      |> Enum.with_index(1)
      |> Enum.map(fn {line, idx} ->
        [[xs, ys, zs], [xe, ye, ze]] =
          String.split(line, "~", trim: true)
          |> Enum.map(fn part ->
            String.split(part, ",") |> Enum.map(&String.to_integer/1)
          end)

        %__MODULE__{id: idx, x: xs..xe, y: ys..ye, z: zs..ze}
      end)
      |> Enum.sort_by(fn %__MODULE__{z: start.._} -> start end)

    grid =
      Enum.reduce(blocks, Grid.new(), fn block, acc ->
        for x <- block.x, y <- block.y, z <- block.z, reduce: acc do
          grid -> Grid.put(grid, {x, y, z}, block.id)
        end
      end)

    {grid, blocks}
  end

  def fall(%__MODULE__{} = block) do
    %__MODULE__{block | z: Range.shift(block.z, -1)}
  end

  @doc """
  Given an increasing min-z-index sorted set of blocks, recursively drop each
  one until it is stacked on top of something.
  """
  def fall({%Grid{} = grid, block}), do: fall(grid, block)

  def fall(%Grid{} = grid, blocks) when is_list(blocks) do
    Enum.reduce(blocks, {grid, []}, fn block, {grid, acc} ->
      {fallen_grid, fallen_block} = fall(grid, block)
      {fallen_grid, [fallen_block | acc]}
    end)
    |> then(fn {grid, blocks} -> {grid, Enum.reverse(blocks)} end)
  end

  def fall(%Grid{} = grid, %__MODULE__{z: min_z..max_z} = block) do
    if touches_below?(grid, block) do
      # if anywhere on the block touches, leave everything alone
      {grid, block}
    else
      fallen_block = fall(block)
      # otherwise, drop the block down one z-index and try again
      fallen_grid =
        for x <- block.x, y <- block.y, reduce: grid do
          grid -> Grid.delete(grid, {x, y, max_z}) |> Grid.put({x, y, min_z - 1}, block.id)
        end

      fall(fallen_grid, fallen_block)
    end
  end

  def touches_below?(%Grid{} = grid, %__MODULE__{z: min_z.._} = block) do
    Enum.any?(xy_points(block), fn {x, y} ->
      touches_below?(grid, {x, y, min_z})
    end)
  end

  def touches_below?(_, {_, _, 1}), do: true

  def touches_below?(%Grid{} = grid, {x, y, z}) do
    Grid.member?(grid, {x, y, z - 1})
  end

  def xy_points(%__MODULE__{} = block) do
    for x <- block.x, y <- block.y, do: {x, y}
  end
end
