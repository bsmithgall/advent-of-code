defimpl Inspect, for: Grid do
  import Inspect.Algebra

  def inspect(grid, opts) do
    concat(
      line(),
      Enum.map(Grid.y_extent_r(grid), fn idy ->
        concat(
          Inspect.inspect(
            Enum.map(Grid.x_extent_r(grid), fn idx ->
              case Grid.get(grid, {idx, idy}) do
                nil -> ~c"."
                v -> v
              end
            end)
            |> Enum.join(),
            opts
          ),
          line()
        )
      end)
      |> concat()
    )
  end
end
