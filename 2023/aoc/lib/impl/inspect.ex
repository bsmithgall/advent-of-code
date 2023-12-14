defimpl Inspect, for: Grid do
  import Inspect.Algebra

  def inspect(grid, opts) do
    concat(
      line(),
      Enum.map(0..grid.h, fn idx ->
        concat(Inspect.inspect(Grid.at_row(grid, idx) |> Enum.join(), opts), line())
      end)
      |> concat()
    )
  end
end
