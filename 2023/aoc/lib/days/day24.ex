defmodule Days.Day24 do
  @behaviour Days.Day

  defstruct px: 0, py: 0, pz: 0, vx: 0, vy: 0, vz: 0

  @impl Days.Day
  def part_one(input, start \\ 200_000_000_000_000, finish \\ 400_000_000_000_000) do
    stones = input |> String.split("\n", trim: true) |> Enum.map(&parse_line/1)

    for a <- stones, b <- stones, a != b, reduce: 0 do
      acc ->
        case linear_intersect(a, b) do
          :none ->
            acc

          {x, y} ->
            if future?(a, {x, y}) and future?(b, {x, y}) and between?(x, start, finish) and
                 between?(y, start, finish) do
              acc + 1
            else
              acc
            end
        end
    end
    |> Kernel./(2)
    |> trunc()
  end

  @impl Days.Day
  def part_two(input) do
    case System.cmd("python", ["priv/24.py", input]) do
      {raw, 0} -> raw |> String.to_integer()
      {error, _} -> error
    end
  end

  def parse_line(line) do
    Regex.named_captures(
      ~r/(?<px>\d+),\s+(?<py>\d+),\s+(?<pz>\d+)\s+@\s+(?<vx>-?\d+),\s+(?<vy>-?\d+),\s+(?<vz>-?\d+)/,
      line
    )
    |> then(fn v ->
      %__MODULE__{
        px: String.to_integer(v["px"]),
        py: String.to_integer(v["py"]),
        pz: String.to_integer(v["pz"]),
        vx: String.to_integer(v["vx"]),
        vy: String.to_integer(v["vy"]),
        vz: String.to_integer(v["vz"])
      }
    end)
  end

  @doc """
  only checks x/y position as per part 1. Modified from: https://paulbourke.net/geometry/pointlineplane/
  """
  def linear_intersect(%__MODULE__{} = a, %__MODULE__{} = b) do
    a2 = step(a)
    b2 = step(b)

    {x1, y1} = {a.px, a.py}
    {x2, y2} = {a2.px, a2.py}
    {x3, y3} = {b.px, b.py}
    {x4, y4} = {b2.px, b2.py}

    denom = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1)

    if denom == 0 do
      :none
    else
      ua = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / denom

      x = x1 + ua * (x2 - x1)
      y = y1 + ua * (y2 - y1)

      {x, y}
    end
  end

  def step(%__MODULE__{} = a) do
    %__MODULE__{a | px: a.px + a.vx, py: a.py + a.vy, pz: a.pz + a.vz}
  end

  def future?(%__MODULE__{px: px, py: py, vx: vx, vy: vy}, {x, y}) do
    ((sign(vx) == 1 and x > px) or (sign(vx) == -1 and x < px)) and
      ((sign(vy) == 1 and y > py) or (sign(vy) == -1 and y < py))
  end

  def sign(int) when int <= 0, do: -1
  def sign(int) when int > 0, do: 1

  def between?(a, start, finish) do
    a > start and a < finish
  end

  def permutations([]), do: [[]]

  def permutations(list),
    do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])

  def without_repetitions(list, k) do
    for head <- list, tail <- without_repetitions(list -- [head], k - 1), do: [head | tail]
  end

  def with_repetitions(list, k) do
    for head <- list, tail <- with_repetitions(list, k - 1), do: [head | tail]
  end
end
