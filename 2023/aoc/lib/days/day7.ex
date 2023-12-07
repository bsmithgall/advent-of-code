defmodule Days.Day7 do
  @behaviour Days.Day

  defstruct hand: [], freqs: [], bid: 0, hv: 0

  @impl Days.Day
  def part_one(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn h -> parse_hand(h, &hand_value/1) end)
    |> Enum.sort(fn h1, h2 -> card_compare(h1, h2, &card_value/1) end)
    |> Enum.sort_by(& &1.hv, :asc)
    |> Enum.with_index(1)
    |> Enum.map(fn {%__MODULE__{bid: bid}, idx} -> bid * idx end)
    |> Enum.sum()
  end

  @impl Days.Day
  def part_two(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn h -> parse_hand(h, &hand_value_jokers/1) end)
    |> Enum.sort(fn h1, h2 -> card_compare(h1, h2, fn c -> card_value(c, :joker) end) end)
    |> Enum.sort_by(& &1.hv, :asc)
    |> Enum.with_index(1)
    |> Enum.map(fn {%__MODULE__{bid: bid}, idx} -> bid * idx end)
    |> Enum.sum()
  end

  def hand_value(%__MODULE__{freqs: freqs}), do: hand_value(freqs)

  def hand_value(freqs) when is_map(freqs) do
    max = freqs |> Map.values() |> Enum.max()

    cond do
      max == 5 -> 7
      max == 4 -> 6
      max == 3 and map_size(freqs) == 2 -> 5
      max == 3 and map_size(freqs) == 3 -> 4
      max == 2 and map_size(freqs) == 3 -> 3
      max == 2 and map_size(freqs) == 4 -> 2
      max == 1 -> 1
    end
  end

  def hand_value_jokers(freqs) do
    joker_count = Map.get(freqs, "J", 0)

    max =
      freqs
      |> Map.reject(fn {k, _} -> k == "J" end)
      |> Map.values()
      |> Enum.max(&>=/2, fn -> 0 end)

    cond do
      joker_count == 0 -> hand_value(freqs)
      max + joker_count == 5 -> 7
      max + joker_count == 4 -> 6
      max + joker_count == 3 and map_size(freqs) == 3 -> 5
      max + joker_count == 3 and map_size(freqs) == 4 -> 4
      max + joker_count == 2 and map_size(freqs) == 4 -> 3
      max + joker_count == 2 and map_size(freqs) == 5 -> 2
    end
  end

  def card_compare(%__MODULE__{} = l, %__MODULE__{} = r, card_value_fn) do
    0..(length(l.hand) - 1)
    |> Enum.reduce_while(0, fn idx, acc ->
      l_card_value = Enum.at(l.hand, idx) |> card_value_fn.()
      r_card_value = Enum.at(r.hand, idx) |> card_value_fn.()

      cond do
        l_card_value > r_card_value -> {:halt, false}
        r_card_value > l_card_value -> {:halt, true}
        l_card_value == r_card_value -> {:cont, acc + 1}
      end
    end)
  end

  def parse_hand(row, hv_func) do
    [hand, bid] = String.trim(row) |> String.split(" ")
    freqs = hand |> String.graphemes() |> Enum.frequencies()

    %__MODULE__{
      hand: hand |> String.graphemes(),
      freqs: hand |> String.graphemes() |> Enum.frequencies(),
      bid: bid |> Utils.try_int(),
      hv: hv_func.(freqs)
    }
  end

  defp card_value(card) do
    Enum.find_index(
      ["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"],
      &(&1 == card)
    )
  end

  defp card_value(card, :joker) do
    Enum.find_index(
      ["J", "2", "3", "4", "5", "6", "7", "8", "9", "T", "Q", "K", "A"],
      &(&1 == card)
    )
  end
end
