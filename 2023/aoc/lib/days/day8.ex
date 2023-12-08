defmodule Days.Day8 do
  @behaviour Days.Day

  defstruct l: "", r: ""

  @impl Days.Day
  def part_one(input) do
    {steps, maps} = parse_input(input)

    calculate_steps(steps, maps, "AAA", &(&1 == "ZZZ"))
  end

  @impl Days.Day
  def part_two(input) do
    {steps, maps} = parse_input(input)

    Map.keys(maps)
    |> Enum.filter(&String.ends_with?(&1, "A"))
    |> Enum.map(&calculate_steps(steps, maps, &1, fn step -> String.ends_with?(step, "Z") end))
    |> Enum.reduce(1, fn step, acc -> Utils.lcm(step, acc) |> trunc() end)
  end

  def parse_input(input) do
    [steps, maps] = input |> String.split("\n\n", trim: true)

    maps =
      maps
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.map(fn map ->
        Regex.named_captures(~r/(?<name>\w+) = \((?<l>\w+), (?<r>\w+)\)/, map)
      end)
      |> Enum.reduce(%{}, fn %{"name" => name, "l" => l, "r" => r}, acc ->
        Map.put(acc, name, %__MODULE__{l: l, r: r})
      end)

    steps = String.graphemes(steps)

    {steps, maps}
  end

  def calculate_steps(steps, maps, from, to_func) do
    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while(from, fn step, spot ->
      next = Map.get(maps, spot)
      dir = Enum.at(steps, rem(step, length(steps)))

      cond do
        to_func.(spot) == true -> {:halt, step}
        dir == "L" -> {:cont, next.l}
        dir == "R" -> {:cont, next.r}
      end
    end)
  end

  # alternatively, recursive implementation

  def calculate_steps_r(steps, maps, from, to_func) do
    calculate_steps_r(0, steps, maps, from, to_func)
  end

  def calculate_steps_r(step, steps, maps, from, to_func) do
    next = Map.get(maps, from)
    dir = Enum.at(steps, rem(step, length(steps)))

    cond do
      to_func.(from) == true -> step
      dir == "L" -> calculate_steps_r(step + 1, steps, maps, next.l, to_func)
      dir == "R" -> calculate_steps_r(step + 1, steps, maps, next.r, to_func)
    end
  end
end
