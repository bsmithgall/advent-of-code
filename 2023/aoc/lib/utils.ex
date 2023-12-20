defmodule Utils do
  def intable?(s) do
    case Integer.parse(s) do
      :error -> false
      _ -> true
    end
  end

  def try_int(s) when is_list(s) do
    s |> Enum.map(&try_int/1)
  end

  def try_int(s) when is_binary(s) do
    case Integer.parse(s) do
      :error -> s
      {v, _} -> v
    end
  end

  @spec gcd(number(), number()) :: number()
  def gcd(a, 0), do: a
  def gcd(0, b), do: b
  def gcd(a, b), do: gcd(b, rem(a, b))

  @spec lcm(number(), number()) :: number()
  def lcm(0, 0), do: 0
  def lcm(a, b), do: a * b / gcd(a, b)

  @spec lcm(list()) :: number()
  def lcm(items), do: Enum.reduce(items, 1, fn i, acc -> Utils.lcm(i, acc) |> trunc() end)
end
