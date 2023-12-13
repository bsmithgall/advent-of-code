defmodule Days.Day13 do
  @behaviour Days.Day

  @impl Days.Day
  def part_one(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(&Grid.from_input/1)
    |> Enum.map(&error_count/1)
    |> Enum.sum()
  end

  @impl Days.Day
  def part_two(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(&Grid.from_input/1)
    |> Enum.map(&error_count(&1, 1))
    |> Enum.sum()
  end

  def error_count(%Grid{} = grid, desired_ct \\ 0) do
    with 0 <- vertical_error_count(grid, desired_ct) do
      horizontal_error_count(grid, desired_ct)
    end
  end

  def vertical_error_count(%Grid{} = grid, desired_ct \\ 0) do
    Enum.reduce_while(0..(grid.w - 1), 0, fn idx, acc ->
      case mismatch_count(grid, :v, idx, idx + 1, 0) do
        ^desired_ct -> {:halt, idx + 1}
        _ -> {:cont, acc}
      end
    end)
  end

  def horizontal_error_count(%Grid{} = grid, desired_ct \\ 0) do
    Enum.reduce_while(0..(grid.h - 1), 0, fn idx, acc ->
      case mismatch_count(grid, :h, idx, idx + 1, 0) do
        ^desired_ct -> {:halt, (idx + 1) * 100}
        _ -> {:cont, acc}
      end
    end)
  end

  def mismatch_count(_, _, l, _, err_count) when l < 0, do: err_count
  def mismatch_count(%Grid{} = grid, :v, _, r, err_count) when r > grid.w, do: err_count
  def mismatch_count(%Grid{} = grid, :h, _, r, err_count) when r > grid.h, do: err_count

  def mismatch_count(%Grid{} = grid, :v, l, r, err_count) do
    errs =
      Grid.at_col(grid, l)
      |> Enum.zip(Grid.at_col(grid, r))
      |> Enum.count(fn {l, r} -> l != r end)

    mismatch_count(grid, :v, l - 1, r + 1, err_count + errs)
  end

  def mismatch_count(%Grid{} = grid, :h, l, r, err_count) do
    errs =
      Grid.at_row(grid, l)
      |> Enum.zip(Grid.at_row(grid, r))
      |> Enum.count(fn {l, r} -> l != r end)

    mismatch_count(grid, :h, l - 1, r + 1, err_count + errs)
  end
end
