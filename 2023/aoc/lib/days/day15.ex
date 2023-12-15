defmodule Days.Day15 do
  @behaviour Days.Day

  @impl Days.Day
  def part_one(input) do
    input |> String.trim() |> String.split(",") |> Enum.map(&hash/1) |> Enum.sum()
  end

  @impl Days.Day
  def part_two(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.reverse/1)
    |> Enum.reduce(0..255 |> Enum.map(&{&1, []}) |> Enum.into(%{}), &hashmap/2)
    |> Enum.reduce(0, fn {k, v}, acc ->
      acc +
        (Enum.with_index(v, 1)
         |> Enum.map(fn {{_, len}, idx} -> (k + 1) * idx * len end)
         |> Enum.sum())
    end)
  end

  def hash(string) do
    String.to_charlist(string)
    |> Enum.reduce(0, fn char, acc ->
      acc |> Kernel.+(char) |> Kernel.*(17) |> rem(256)
    end)
  end

  def hashmap(<<"-", label::binary>>, acc) do
    label = String.reverse(label)
    to = hash(label)
    current = Map.get(acc, to)
    current_index = Enum.find_index(current, fn i -> elem(i, 0) == label end)

    if is_nil(current_index) do
      acc
    else
      {_, new} = List.pop_at(current, current_index)
      Map.put(acc, to, new)
    end
  end

  def hashmap(<<len::binary-1, "=", label::binary>>, acc) do
    label = String.reverse(label)
    to = hash(label)
    current = Map.get(acc, to)
    current_index = Enum.find_index(current, fn i -> elem(i, 0) == label end)

    if is_nil(current_index) do
      Map.put(acc, to, current ++ [{label, String.to_integer(len)}])
    else
      Map.put(acc, to, List.replace_at(current, current_index, {label, String.to_integer(len)}))
    end
  end
end
