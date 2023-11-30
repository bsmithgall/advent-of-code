defmodule Days.Day do
  @type t :: module()

  @callback part_one(String.t()) :: String.t() | integer()
  @callback part_two(String.t()) :: String.t() | integer()

  @spec exec(t(), binary()) ::
          {{:erlang.time_unit(), String.t() | integer()},
           {:erlang.time_unit(), String.t() | integer()}}
  def exec(day, input) do
    {
      :timer.tc(day, :part_one, [input]),
      :timer.tc(day, :part_two, [input])
    }
  end
end
