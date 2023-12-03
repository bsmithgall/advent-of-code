defmodule Utils do
  def intable?(s) do
    case Integer.parse(s) do
      :error -> false
      _ -> true
    end
  end

  def try_int(s) do
    case Integer.parse(s) do
      :error -> s
      {v, _} -> v
    end
  end
end
