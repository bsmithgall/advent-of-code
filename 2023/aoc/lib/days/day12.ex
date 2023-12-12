defmodule Days.Day12 do
  @behaviour Days.Day

  @impl Days.Day
  def part_one(input) do
    Memoize.start()

    parse_input(input)
    |> Enum.map(fn {status, constraints} -> count(status, constraints) end)
    |> Enum.sum()
  end

  @impl Days.Day
  def part_two(input) do
    Memoize.start()

    parse_input(input)
    |> Enum.map(fn {status, constraints} ->
      {
        status |> String.split("", trim: true) |> List.duplicate(5) |> Enum.join("?"),
        constraints |> List.duplicate(5) |> List.flatten()
      }
    end)
    |> Enum.map(&count(elem(&1, 0), elem(&1, 1)))
    |> Enum.sum()
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.split(&1, ~r/\s+/))
    |> Enum.map(fn [status, constraint] ->
      {
        status,
        String.split(constraint, ",") |> Enum.map(&Utils.try_int/1)
      }
    end)
  end

  def count(status, constraints), do: count(status, ".", constraints)

  # base cases: status string is empty
  def count("", _, []), do: 1
  def count("", _, [0]), do: 1
  def count("", _, _), do: 0
  # head character is broken and we've exhausted our constraints
  def count("#" <> _, _, []), do: 0
  def count("#" <> _, _, [0 | []]), do: 0
  # head character is broken but there are still constraints, forward along
  def count("#" <> springs, _, [h | t]), do: count(springs, "#", [h - 1 | t])
  # head character is working, forward along to the next character
  def count("." <> springs, _, []), do: count(springs, ".", [])
  def count("." <> springs, "#", [0 | t]), do: count(springs, ".", t)
  def count("." <> _, "#", _), do: 0
  def count("." <> springs, ".", constraints), do: count(springs, ".", constraints)
  # head character is ? -- these all forward down into the memoized method which
  # generates counts for each possible case
  def count("?" <> springs, "#", []), do: count(springs, ".", [])
  def count("?" <> springs, "#", [0 | t]), do: count(springs, ".", t)
  def count("?" <> springs, "#", [h | t]), do: count(springs, "#", [h - 1 | t])
  def count("?" <> springs, ".", []), do: count(springs, ".", [])
  def count("?" <> springs, ".", [0 | t]), do: count(springs, ".", t)

  def count("?" <> springs, ".", [h | t]) do
    Memoize.memoize({springs, [h | t]}, fn ->
      count(springs, "#", [h - 1 | t]) + count(springs, ".", [h | t])
    end)
  end

  # slow original part 1 implementation (~30s with Enum.map, ~8s with Task.async_stream)

  def part_one_slow(input) do
    parse_input(input)
    |> Task.async_stream(
      fn {status, constraints} ->
        status
        |> slow_permutations()
        |> Enum.count(fn perm ->
          String.split(perm, ".", trim: true) |> Enum.map(&String.length/1) ==
            constraints
        end)
      end,
      ordered: false,
      timeout: :infinity
    )
    |> Stream.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def slow_permutations(str), do: slow_permutations(str, "")
  def slow_permutations("", combination), do: [combination]

  def slow_permutations(<<h::binary-1, rest::binary>>, combination) when h != "?" do
    slow_permutations(rest, combination <> h)
  end

  def slow_permutations(<<"?", rest::binary>>, combination) do
    Enum.reduce(~w[. #], [], fn c, acc ->
      slow_permutations(rest, combination <> c) ++ acc
    end)
    |> Enum.uniq()
  end
end
