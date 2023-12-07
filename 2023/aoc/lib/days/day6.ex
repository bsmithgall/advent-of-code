defmodule Days.Day6 do
  @behaviour Days.Day

  @impl Days.Day
  def part_one(input) do
    races =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, ~r/\s+/))
      |> Enum.map(fn [_ | cons] -> cons end)
      |> Enum.map(&Utils.try_int/1)
      |> Enum.zip()

    Enum.map(races, fn {time, distance} ->
      0..time
      |> Enum.reduce(0, fn t, acc ->
        case t * (time - t) do
          d when d > distance -> acc + 1
          _ -> acc
        end
      end)
    end)
    |> Enum.product()
  end

  @impl Days.Day
  def part_two(input) do
    [time, distance] =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, ~r/\s+/))
      |> Enum.map(fn [_ | cons] -> cons end)
      |> Enum.map(&Enum.join/1)
      |> Enum.map(&Utils.try_int/1)

    0..time
    |> Enum.reduce(0, fn t, acc ->
      case t * (time - t) do
        d when d > distance -> acc + 1
        _ -> acc
      end
    end)
  end
end
