defmodule Days.Day17 do
  @behaviour Days.Day

  defmodule PQ do
    defstruct [:set]

    def new([_ | _] = list), do: %__MODULE__{set: :gb_sets.from_list(list)}

    def push(%__MODULE__{} = pq, {elem, priority}) do
      %{pq | set: :gb_sets.add({priority, elem}, pq.set)}
    end

    def min_priority(%__MODULE__{} = pq) do
      case :gb_sets.size(pq.set) do
        0 ->
          :empty

        _ ->
          :gb_sets.take_smallest(pq.set)
          |> then(fn {{prio, elem}, set} -> {{prio, elem}, %{pq | set: set}} end)
      end
    end
  end

  defstruct coord: {0, 0}, dir: :n, step: 0

  @impl Days.Day
  def part_one(input) do
    Grid.from_input(input, &String.to_integer/1) |> solve(1, 3)
  end

  @impl Days.Day
  def part_two(input) do
    Grid.from_input(input, &String.to_integer/1) |> solve(4, 10)
  end

  def solve(%Grid{} = grid, step_min, step_max) do
    start_queue =
      PQ.new([
        {Grid.get(grid, {0, 1}), %__MODULE__{coord: {0, 1}, dir: :s, step: 1}},
        {Grid.get(grid, {1, 0}), %__MODULE__{coord: {1, 0}, dir: :e, step: 1}}
      ])

    start_seen = MapSet.new()

    solve(start_queue, start_seen, grid, step_min, step_max)
  end

  def solve(%PQ{} = queue, %MapSet{} = seen, %Grid{} = grid, step_min, step_max) do
    {{w, %__MODULE__{} = s}, queue} = PQ.min_priority(queue)

    cond do
      MapSet.member?(seen, s) ->
        solve(queue, seen, grid, step_min, step_max)

      s.coord == Grid.extent(grid) and s.step >= step_min ->
        w

      true ->
        List.flatten([step(s, step_max), turn(s, step_min)])
        |> Enum.filter(fn s -> MapSet.member?(grid.coords, s.coord) end)
        |> Enum.map(fn s -> {s, Grid.get(grid, s.coord) + w} end)
        |> Enum.reduce(queue, fn s, acc -> PQ.push(acc, s) end)
        |> solve(MapSet.put(seen, s), grid, step_min, step_max)
    end
  end

  def step(%__MODULE__{} = s, step_max) when s.step >= step_max, do: []

  def step(%__MODULE__{} = s, _) do
    {x, y} = s.coord

    case s.dir do
      :n -> %__MODULE__{coord: {x, y - 1}, dir: s.dir, step: s.step + 1}
      :s -> %__MODULE__{coord: {x, y + 1}, dir: s.dir, step: s.step + 1}
      :e -> %__MODULE__{coord: {x + 1, y}, dir: s.dir, step: s.step + 1}
      :w -> %__MODULE__{coord: {x - 1, y}, dir: s.dir, step: s.step + 1}
    end
  end

  def turn(%__MODULE__{} = s, step_min) when s.step < step_min, do: []

  def turn(%__MODULE__{} = s, _) do
    {x, y} = s.coord

    case s.dir do
      d when d == :n or d == :s ->
        [
          %__MODULE__{coord: {x + 1, y}, dir: :e, step: 1},
          %__MODULE__{coord: {x - 1, y}, dir: :w, step: 1}
        ]

      d when d == :e or d == :w ->
        [
          %__MODULE__{coord: {x, y - 1}, dir: :n, step: 1},
          %__MODULE__{coord: {x, y + 1}, dir: :s, step: 1}
        ]
    end
  end
end
