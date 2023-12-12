defmodule Memoize do
  use GenServer

  def start() do
    {status, _} = start_link()
    if status == :error, do: Memoize.clear()
  end

  def start_link(), do: GenServer.start_link(__MODULE__, Map.new(), name: __MODULE__)

  @doc """
  Memoize the "right" way with a GenServer
  """
  def memoize(key, func) do
    case GenServer.call(__MODULE__, {:get, key}) do
      {:ok, v} ->
        v

      :miss ->
        func.()
        |> then(fn v ->
          GenServer.cast(__MODULE__, {:put, key, v})
          v
        end)
    end
  end

  @doc """
  Memoize with a process dictionary
  """
  def proc_memoize(key, func) do
    case Process.get(key) do
      nil ->
        func.()
        |> then(fn v ->
          Process.put(key, v)
          v
        end)

      v ->
        v
    end
  end

  def clear(), do: GenServer.call(__MODULE__, :clear)

  @impl true
  def init(_) do
    {:ok, Map.new()}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    case Map.get(state, key) do
      nil -> {:reply, :miss, state}
      v -> {:reply, {:ok, v}, state}
    end
  end

  @impl true
  def handle_call(:clear, _, _) do
    {:reply, :ok, %{}}
  end

  @impl true
  def handle_cast({:put, key, v}, state) do
    {:noreply, Map.put(state, key, v)}
  end
end
