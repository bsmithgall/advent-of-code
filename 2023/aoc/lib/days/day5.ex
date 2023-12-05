defmodule Days.Day5 do
  @behaviour Days.Day

  defstruct source: 0, dest: 0, len: 0

  @impl Days.Day
  def part_one(input) do
    [seeds | maps] = input |> String.split("\n\n")

    seeds =
      seeds
      |> String.trim()
      |> String.replace("seeds: ", "")
      |> String.split(" ")
      |> Enum.map(&Utils.try_int/1)

    maps = maps |> Enum.map(&parse_map/1)

    seeds
    |> Enum.map(fn seed ->
      Enum.reduce(maps, seed, fn map, v ->
        Enum.reduce_while(map, v, &walk_map/2)
      end)
    end)
    |> Enum.min()
  end

  # @impl Days.Day
  # def part_two(input) do
  #   go(input)
  # end

  @impl Days.Day
  def part_two(input) do
    [seeds | maps] = input |> String.split("\n\n")

    # The input is far too big to brute force, so we have to do range
    # calculations.

    seeds =
      seeds
      |> String.trim()
      |> String.replace("seeds: ", "")
      |> String.split(" ")
      |> Enum.map(&Utils.try_int/1)
      |> Enum.chunk_every(2)
      |> Enum.map(fn [l, r] -> Range.new(l, l + (r - 1)) end)

    # First, parse each map to be a %{Range => length} for fast distance lookups
    maps =
      maps
      |> Enum.map(&parse_map/1)
      |> Enum.map(fn maps ->
        Enum.reduce(maps, %{}, fn %__MODULE__{} = map, acc ->
          Map.put(acc, map.source..(map.source + (map.len - 1)), map.dest - map.source)
        end)
      end)

    # For each map in our list of resource maps...
    maps
    |> Enum.reduce(seeds, fn map, seeds ->
      # ... for each seed range in our range pairs ...
      seeds
      |> Enum.reduce([], fn seed_range, ranges_acc ->
        map
        |> Map.keys()
        # ... for each range => diff key/value in our maps ...
        |> Enum.reduce({[seed_range], []}, fn map_first..map_last = map_range,
                                              {seed_range, acc2} ->
          seed_range
          # generate a new tuple of {untouched, transformed} ranges based on the
          # overlapping conditions of the seed & map ranges
          |> Enum.reduce({[], acc2}, fn seed_first..seed_last = seed_range,
                                        {untouched, transformed} ->
            diff = Map.get(map, map_range)

            cond do
              # no overlap between the seed range and the map range, add original
              # seed_range to untouched
              Range.disjoint?(map_range, seed_range) ->
                {[seed_range | untouched], transformed}

              # map is before seed and overlaps with it to some degree
              map_first < seed_first and (map_last == seed_first or map_last < seed_last) ->
                {[(seed_first + 1)..seed_last | untouched],
                 [Range.shift(seed_first..seed_first, diff) | transformed]}

              # map completely contains seed
              map_first < seed_first and map_last >= seed_last ->
                {untouched, [Range.shift(seed_first..seed_last, diff) | transformed]}

              # map is completely contained by seed
              map_first == seed_first and (map_last == seed_first or map_last < seed_last) ->
                {[(map_last + 1)..seed_last | untouched],
                 [Range.shift(seed_first..map_last, diff) | transformed]}

              # map starts at the seed, but overruns it
              map_first == seed_first and map_last >= seed_last ->
                {untouched, [Range.shift(seed_first..seed_last, diff) | transformed]}

              # map is completely contained by seed
              map_first > seed_first and map_last < seed_last ->
                {[seed_first..(map_first - 1), (map_last + 1)..seed_last | untouched],
                 [Range.shift(map_first..map_last, diff) | transformed]}

              # map starts in the middle of seed but overruns it
              map_first > seed_first and map_last >= seed_last ->
                {[seed_first..(map_first - 1) | untouched],
                 [Range.shift(map_first..seed_last, diff) | transformed]}

              # map and seed only overlap by the last value
              map_first == seed_last and map_last >= seed_last ->
                {[seed_first..(seed_last - 1) | untouched],
                 [Range.shift(map_first..seed_last, diff) | transformed]}
            end
          end)
        end)
        # merge all ranges together
        |> then(fn {untouched, transformed} -> untouched ++ transformed ++ ranges_acc end)
      end)
    end)
    |> Enum.flat_map(fn s..f -> [s, f] end)
    |> Enum.min()
  end

  def parse_map(line) do
    [_ | cons] = line |> String.trim() |> String.split("\n") |> Enum.map(&String.trim/1)

    cons
    |> Enum.map(&String.split(&1, ~r/\s/))
    |> Enum.map(fn [dest, source, len] ->
      %__MODULE__{
        source: Utils.try_int(source),
        dest: Utils.try_int(dest),
        len: Utils.try_int(len)
      }
    end)
  end

  def walk_map(%__MODULE__{source: source}, value) when value < source, do: {:cont, value}

  def walk_map(%__MODULE__{source: source, len: len}, value) when value > source + len,
    do: {:cont, value}

  def walk_map(%__MODULE__{} = map, value) do
    {:halt, map.dest + value - map.source}
  end
end
