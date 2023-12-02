defmodule Days.Day2 do
  @behaviour Days.Day

  defstruct red: 0, green: 0, blue: 0

  @impl Days.Day
  def part_one(input) do
    input |> String.split("\n") |> Enum.map(&process_line/1) |> Enum.sum()
  end

  @impl Days.Day
  def part_two(input) do
    input |> String.split("\n") |> Enum.map(&process_line_two/1) |> Enum.sum()
  end

  def process_line(""), do: 0

  def process_line(line) do
    [id, games] = String.split(line, ": ")

    case games
         |> parse_games()
         |> Enum.all?(&part_one_possible?/1) do
      true -> parse_id(id)
      false -> 0
    end
  end

  def part_one_possible?(%__MODULE__{} = game) do
    game.red <= 12 and game.green <= 13 && game.blue <= 14
  end

  def parse_id(id) do
    id |> String.replace(~r/[^\d]/, "") |> String.to_integer()
  end

  def process_line_two(""), do: 0

  def process_line_two(line) do
    [_id, games] = String.split(line, ": ")

    parse_games(games)
    |> Enum.reduce(%__MODULE__{}, &max_game/2)
    |> times()
  end

  def parse_games(games) do
    games |> String.split("; ") |> Enum.map(&String.split(&1, ", ")) |> Enum.map(&parse_game/1)
  end

  def parse_game(game) do
    game
    |> Enum.map(&String.split(&1, " "))
    |> Enum.reduce(%__MODULE__{}, fn color, acc ->
      [ct, name] = color
      Map.merge(acc, %{String.to_atom(name) => String.to_integer(ct)})
    end)
  end

  def max_game(l, r) do
    %__MODULE__{
      red: max(l.red, r.red),
      blue: max(l.blue, r.blue),
      green: max(l.green, r.green)
    }
  end

  def times(%__MODULE__{} = game) do
    game.red * game.green * game.blue
  end
end
