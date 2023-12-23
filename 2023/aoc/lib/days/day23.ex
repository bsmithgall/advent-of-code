defmodule Days.Day23 do
  @behaviour Days.Day

  defmodule Graph do
    defstruct e: %{}, w: %{}

    def new(), do: %__MODULE__{e: %{}, w: %{}}

    def add_edge(%Graph{} = g, v1, v2, weight) do
      %__MODULE__{
        e: Map.update(g.e, v1, MapSet.new([v2]), fn ex -> MapSet.put(ex, v2) end),
        w: Map.put(g.w, {v1, v2}, weight)
      }
    end

    def get_edge(%Graph{} = g, v1, v2) do
      {
        Map.get(g.e, v1, MapSet.new())
        |> MapSet.filter(&(&1 == v2))
        |> MapSet.to_list()
        |> hd(),
        Map.get(g.w, {v1, v2})
      }
    end

    def edges(%Graph{} = g, v) do
      Map.get(g.e, v, MapSet.new())
    end

    def get_paths(%Graph{} = g, from, to) do
      case dfs(g, edges(g, from), to, [from], []) do
        [] -> []
        paths -> paths
      end
    end

    def dfs(%Graph{} = g, %MapSet{} = neighbors, to, path, paths) when is_list(paths) do
      {paths, seen} =
        if MapSet.member?(neighbors, to) do
          {[Enum.reverse([to | path]) | paths], [to | path]}
        else
          {paths, path}
        end

      neighbors = MapSet.difference(neighbors, MapSet.new(seen))
      dfs(g, MapSet.to_list(neighbors), to, path, paths)
    end

    def dfs(_, [], _, _, paths) when is_list(paths), do: paths

    def dfs(%Graph{} = g, [next_neighbor | neighbors], to, path, paths) do
      next_neighbors = edges(g, next_neighbor)

      if MapSet.size(next_neighbors) == 0 do
        dfs(g, neighbors, to, path, paths)
      else
        case dfs(g, next_neighbors, to, [next_neighbor | path], paths) do
          [] -> dfs(g, neighbors, to, path, paths)
          n_paths -> dfs(g, neighbors, to, path, n_paths)
        end
      end
    end
  end

  @impl Days.Day
  def part_one(input) do
    grid = Grid.from_input(input)

    start = {1, 0}
    dest = {grid.w - 1, grid.h}

    to_graph(grid, start, dest) |> longest_path(start, dest)
  end

  @impl Days.Day
  def part_two(input) do
    grid = Grid.from_input(input)

    start = {1, 0}
    dest = {grid.w - 1, grid.h}

    to_graph(grid, start, dest, true) |> longest_path(start, dest)
  end

  def longest_path(%Graph{} = graph, start, dest) do
    Graph.get_paths(graph, start, dest)
    |> Task.async_stream(fn path ->
      Enum.chunk_every(path, 2, 1, :discard)
      |> Enum.reduce(0, fn [v1, v2], acc ->
        {_, weight} = Graph.get_edge(graph, v1, v2)
        acc + weight
      end)
    end)
    |> Stream.map(&elem(&1, 1))
    |> Enum.max()
  end

  def to_graph(%Grid{} = grid, start, dest, bi \\ false),
    do: to_graph(Graph.new(), grid, start, start, dest, 0, MapSet.new(), bi)

  def to_graph(%Graph{} = graph, _, from, dest, dest, dist, _, false) do
    Graph.add_edge(graph, from, dest, dist)
  end

  def to_graph(%Graph{} = graph, _, from, dest, dest, dist, _, true) do
    Graph.add_edge(graph, from, dest, dist)
    |> Graph.add_edge(dest, from, dist)
  end

  def to_graph(%Graph{} = graph, %Grid{} = grid, from, current, dest, dist, seen, bi) do
    seen = MapSet.put(seen, current)

    case get_neighbors(grid, current, seen) do
      [] ->
        graph

      [next] ->
        to_graph(graph, grid, from, next, dest, dist + 1, seen, bi)

      [_ | _] = nexts ->
        g = Graph.add_edge(graph, from, current, dist)
        g = if bi, do: Graph.add_edge(g, current, from, dist), else: g

        Enum.reduce(nexts, g, fn next, acc ->
          to_graph(acc, grid, current, next, dest, 1, seen, bi)
        end)
    end
  end

  def get_neighbors(%Grid{} = grid, {x, y} = coord, seen) do
    case Grid.get(grid, coord) do
      "#" -> []
      ">" -> [{x + 1, y}]
      "v" -> [{x, y + 1}]
      "^" -> [{x, y - 1}]
      "<" -> [{x - 1, y}]
      _ -> Grid.get_direct_neighbor_coords(grid, coord)
    end
    |> Enum.filter(&Grid.member?(grid, &1))
    |> Enum.reject(&(Grid.get(grid, &1) == "#"))
    |> Enum.reject(&MapSet.member?(seen, &1))
  end
end
