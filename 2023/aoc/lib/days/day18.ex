defmodule Days.Day18 do
  @behaviour Days.Day

  defstruct dir: "", dist: 0

  @impl Days.Day
  def part_one(input) do
    {_, trench} =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&parse_line/1)
      |> Enum.reduce({{0, 0}, Grid.new()}, fn row, {{x, y}, %Grid{} = grid} ->
        for i <- 1..row.dist, reduce: {{x, y}, grid} do
          {_, grid} ->
            case row.dir do
              "U" -> {{x, y - i}, Grid.put(grid, {x, y - i}, "#")}
              "D" -> {{x, y + i}, Grid.put(grid, {x, y + i}, "#")}
              "L" -> {{x - i, y}, Grid.put(grid, {x - i, y}, "#")}
              "R" -> {{x + i, y}, Grid.put(grid, {x + i, y}, "#")}
            end
        end
      end)

    {x, y} =
      trench.coords
      |> Enum.filter(fn {_, y} -> y == Grid.y_min(trench) end)
      |> Enum.min_by(&elem(&1, 0))

    MapSet.size(trench.coords) +
      (flood(MapSet.new(), trench.coords, {x + 1, y + 1}) |> MapSet.size())
  end

  @impl Days.Day
  def part_two(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_hex_line/1)
    |> Enum.reduce([{0, 0}], fn row, [{x, y} | _] = acc ->
      case row.dir do
        "U" -> [{x, y - row.dist} | acc]
        "D" -> [{x, y + row.dist} | acc]
        "L" -> [{x - row.dist, y} | acc]
        "R" -> [{x + row.dist, y} | acc]
      end
    end)
    |> then(fn points -> perimeter(points) / 2 + shoelace(points) + 1 end)
    |> trunc()
  end

  def parse_line(line) do
    Regex.named_captures(~r/(?<dir>\w) (?<dist>\d+) \((?<color>#\w{6})\)/, line)
    |> then(fn v ->
      %__MODULE__{dir: v["dir"], dist: String.to_integer(v["dist"])}
    end)
  end

  def flood(%MapSet{} = flooded, %MapSet{} = border, {x, y}) do
    flooded = MapSet.put(flooded, {x, y})

    [
      {x, y - 1},
      {x, y + 1},
      {x - 1, y},
      {x + 1, y}
    ]
    |> Enum.reduce(flooded, fn neighbor, flooded ->
      cond do
        neighbor in flooded -> flooded
        neighbor in border -> flooded
        true -> flood(flooded, border, neighbor)
      end
    end)
  end

  def parse_hex_line(line) do
    Regex.named_captures(~r/\w \d+ \(#(?<hex>\w{5})(?<dir>\d)\)/, line)
    |> then(fn v ->
      dir =
        case v["dir"] do
          "0" -> "R"
          "1" -> "D"
          "2" -> "L"
          "3" -> "U"
        end

      {dist, _} = Integer.parse(v["hex"], 16)

      %__MODULE__{dir: dir, dist: dist}
    end)
  end

  @doc """
  Converted from https://rosettacode.org/wiki/Shoelace_formula_for_polygonal_area#Python
  """
  def shoelace(points) when is_list(points), do: Enum.unzip(points) |> shoelace()

  def shoelace({[x_head | x_tail] = x, [y_head | y_tail] = y}) do
    l = Enum.zip(x, y_tail ++ [y_head]) |> Enum.reduce(0, fn {x, y}, acc -> acc + x * y end)
    r = Enum.zip(x_tail ++ [x_head], y) |> Enum.reduce(0, fn {x, y}, acc -> acc + x * y end)

    (abs(l - r) / 2) |> trunc()
  end

  def perimeter([head | tail] = points) do
    Enum.zip(points, tail ++ [head])
    |> Enum.reduce(0, fn {{x1, y1}, {x2, y2}}, acc ->
      acc + :math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)
    end)
  end
end
