defmodule Days.Day20 do
  @behaviour Days.Day

  defprotocol Node do
    @spec type(t) :: atom()
    def type(_)

    @spec ping(t, :high | :low, String.t()) :: {t, :high | :low | :none}
    def ping(t, pulse, from)
  end

  defmodule Empty do
    defstruct name: "", to: [], t: :n

    def new(line) do
      Regex.named_captures(Days.Day20.line_regex(), line)
      |> then(fn v ->
        {v["name"], %Empty{name: v["name"], to: v["to"] |> String.split(", ")}}
      end)
    end

    def new!(name), do: %Empty{name: name}
  end

  defimpl Node, for: Empty do
    def type(_), do: :n
    def ping(%Empty{} = n, _, _), do: {n, :none}
  end

  defmodule FlipFlop do
    defstruct name: "", on: false, to: [], t: :f

    def new(line) do
      Regex.named_captures(Days.Day20.line_regex(), line)
      |> then(fn v ->
        {v["name"], %FlipFlop{name: v["name"], to: v["to"] |> String.split(", ")}}
      end)
    end
  end

  defimpl Node, for: FlipFlop do
    def type(_), do: :f

    def ping(%FlipFlop{} = m, :high, _), do: {m, :none}
    def ping(%FlipFlop{on: false} = m, :low, _), do: {%FlipFlop{m | on: true}, :high}
    def ping(%FlipFlop{on: true} = m, :low, _), do: {%FlipFlop{m | on: false}, :low}
  end

  defmodule Conjunction do
    defstruct name: "", inputs: %{}, to: [], t: :c

    def new(line) do
      Regex.named_captures(Days.Day20.line_regex(), line)
      |> then(fn v ->
        {v["name"], %Conjunction{name: v["name"], to: v["to"] |> String.split(", ")}}
      end)
    end

    @doc """
    We only will know what is going into this Conjunction once we've fully
    parsed, so inputs need to come in separately
    """
    def init_inputs(%__MODULE__{} = m, inputs) do
      %__MODULE__{m | inputs: inputs |> Enum.map(&{&1, :low}) |> Enum.into(%{})}
    end

    def inputs(%__MODULE__{} = m, %{} = nodes) do
      m.inputs |> Map.keys() |> Enum.map(&Map.get(nodes, &1))
    end
  end

  defimpl Node, for: Conjunction do
    def type(_), do: :c

    def ping(%Conjunction{} = m, pulse, from) do
      %Conjunction{m | inputs: Map.put(m.inputs, from, pulse)} |> then(&{&1, send_type(&1)})
    end

    defp send_type(%Conjunction{} = m) do
      if(Map.values(m.inputs) |> Enum.all?(&(&1 == :high)), do: :low, else: :high)
    end
  end

  @impl Days.Day
  def part_one(input) do
    nodes = init_nodes(input)

    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while({nodes, 0, 0, 0}, fn _, {nodes, times, low, high} ->
      {modified, new_low, new_high} = count_pushes(nodes)

      case times + 1 do
        1000 -> {:halt, (low + new_low) * (high + new_high)}
        _ -> {:cont, {modified, times + 1, low + new_low, high + new_high}}
      end
    end)
  end

  @doc """
  When looking at the input, we see four separate subgraphs connecting to `rx`,
  all of which send data to node `lv` which is directly upstream for `rx`. This
  will not work for other inputs.
  """
  @impl Days.Day
  def part_two(input) do
    nodes = init_nodes(input)

    dest =
      Conjunction.inputs(Map.get(nodes, "lv"), nodes) |> Enum.map(&{&1.name, 0}) |> Enum.into(%{})

    pulse_til_high(nodes, dest) |> Map.values() |> Utils.lcm()
  end

  def line_regex, do: ~r/[%&]?(?<name>\w+) -> (?<to>[\w ,]+)/

  def init_nodes(input) do
    nodes =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn str ->
        case String.at(str, 0) do
          "&" -> Conjunction.new(str)
          "%" -> FlipFlop.new(str)
          _ -> Empty.new(str)
        end
      end)
      |> Enum.into(%{})

    conj =
      nodes
      |> Map.values()
      |> Enum.filter(&(&1.t == :c))
      |> Enum.map(& &1.name)
      |> Enum.into(MapSet.new())

    input_map =
      Enum.reduce(nodes, %{}, fn {_, node}, acc ->
        Enum.reduce(node.to, acc, fn to, node_acc ->
          if to in conj do
            Map.update(node_acc, to, [node.name], &(&1 ++ [node.name]))
          else
            node_acc
          end
        end)
      end)

    Enum.map(nodes, fn {name, node} ->
      if node.t == :c do
        {name, Conjunction.init_inputs(node, Map.get(input_map, node.name))}
      else
        {name, node}
      end
    end)
    |> Enum.into(%{})
  end

  def count_pushes(%{} = nodes) do
    count_pushes(
      nodes,
      Map.get(nodes, "broadcaster").to |> Enum.map(&{"broadcaster", &1, :low}),
      {1, 0}
    )
  end

  @spec count_pushes(%{}, [{String.t(), String.t(), :low | :high}], {integer(), integer()}) ::
          {%{}, integer(), integer()}
  def count_pushes(nodes, [], {low, high}), do: {nodes, low, high}

  def count_pushes(%{} = nodes, [{_from, to, pulse} = head | tail], {low, high}) do
    {modified, new_pulse} = send_pulse(nodes, head)

    new_count = if pulse == :high, do: {low, high + 1}, else: {low + 1, high}

    enqueued =
      if new_pulse == :none, do: tail, else: tail ++ Enum.map(modified.to, &{to, &1, new_pulse})

    nodes = Map.put(nodes, modified.name, modified)
    count_pushes(nodes, enqueued, new_count)
  end

  def pulse_til_high(%{} = nodes, %{} = destinations),
    do: pulse_til_high(nodes, destinations, [], 0)

  def pulse_til_high(%{} = nodes, %{} = destinations, [], presses) do
    pulse_til_high(
      nodes,
      destinations,
      Map.get(nodes, "broadcaster").to |> Enum.map(&{"broadcaster", &1, :low}),
      presses + 1
    )
  end

  def pulse_til_high(
        %{} = nodes,
        %{} = destinations,
        [{_from, to, _pulse} = head | tail],
        presses
      ) do
    cond do
      Map.values(destinations) |> Enum.product() > 0 ->
        destinations

      true ->
        {modified, new_pulse} = send_pulse(nodes, head)

        nodes = Map.put(nodes, modified.name, modified)

        destinations =
          if Map.has_key?(destinations, modified.name) and new_pulse == :high,
            do: Map.put(destinations, modified.name, presses),
            else: destinations

        enqueued =
          if new_pulse == :none,
            do: tail,
            else: tail ++ Enum.map(modified.to, &{to, &1, new_pulse})

        pulse_til_high(nodes, destinations, enqueued, presses)
    end
  end

  def send_pulse(%{} = nodes, {from, to, pulse}) do
    receiver = Map.get_lazy(nodes, to, fn -> Empty.new!(to) end)
    Node.ping(receiver, pulse, from)
  end
end
