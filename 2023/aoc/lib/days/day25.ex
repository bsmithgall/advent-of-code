defmodule Days.Day25 do
  @behaviour Days.Day

  @impl Days.Day
  def part_one(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> String.replace(line, ":", "") |> String.split("\s") end)
    |> Enum.reduce({MapSet.new(), MapSet.new()}, fn [v | edges] = all, {vs, es} ->
      {
        MapSet.union(vs, MapSet.new(all)),
        MapSet.union(es, MapSet.new(Enum.map(edges, &{v, &1})))
      }
    end)
    |> then(fn {v, e} -> karger(v, e) end)
    |> then(fn [l, r] -> MapSet.size(l) * MapSet.size(r) end)
  end

  @impl Days.Day
  def part_two(_), do: 0

  def karger(vertices, edges) do
    Enum.map(vertices, fn v -> MapSet.new([v]) end) |> subset(vertices, edges)
  end

  def subset(subsets, vertices, edges) when length(subsets) <= 2 do
    case overlap(subsets, edges) do
      n when n < 4 -> subsets
      _ -> karger(vertices, edges)
    end
  end

  def subset(subsets, vertices, edges) do
    {e1, e2} = Enum.random(edges)
    s1 = find(subsets, e1)
    s2 = find(subsets, e2)

    if s1 == s2 do
      subset(subsets, vertices, edges)
    else
      subset(
        [MapSet.union(s1, s2) | List.delete(subsets, s1) |> List.delete(s2)],
        vertices,
        edges
      )
    end
  end

  def overlap(subsets, edges) do
    Enum.reduce(edges, 0, fn {v1, v2}, acc ->
      if find(subsets, v1) != find(subsets, v2), do: acc + 1, else: acc
    end)
  end

  def find(subsets, v) when is_binary(v), do: Enum.find(subsets, &MapSet.member?(&1, v))
end
