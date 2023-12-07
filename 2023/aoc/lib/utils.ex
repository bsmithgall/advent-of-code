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
end
