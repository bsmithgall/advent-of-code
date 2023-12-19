defmodule Days.Day19 do
  require IEx
  @behaviour Days.Day

  defmodule Part do
    defstruct x: [], m: [], a: [], s: []

    def sum(%__MODULE__{} = p), do: Enum.sum(p.x) + Enum.sum(p.m) + Enum.sum(p.a) + Enum.sum(p.s)

    def combos(%__MODULE__{} = p),
      do: Enum.count(p.x) * Enum.count(p.m) * Enum.count(p.a) * Enum.count(p.s)

    def from_input(string) do
      Regex.named_captures(~r/{x=(?<x>\d+),m=(?<m>\d+),a=(?<a>\d+),s=(?<s>\d+)}/, string)
      |> then(fn v ->
        %__MODULE__{
          x: [String.to_integer(v["x"])],
          m: [String.to_integer(v["m"])],
          a: [String.to_integer(v["a"])],
          s: [String.to_integer(v["s"])]
        }
      end)
    end

    def split(%__MODULE__{} = part, rule) do
      start.._stop = current = Map.get(part, rule.c)

      cond do
        rule.op == (&Kernel.</2) ->
          {l, r} = current |> Range.split(rule.val - start)
          {Map.replace(part, rule.c, l), Map.replace(part, rule.c, r)}

        rule.op == (&Kernel.>/2) ->
          {l, r} = current |> Range.split(rule.val - (start - 1))
          {Map.replace(part, rule.c, r), Map.replace(part, rule.c, l)}
      end
    end
  end

  defmodule Rule do
    defstruct [:c, :op, :val, :to]

    def from_input(string) do
      parts = String.split(string, ~r/<|>|:/)
      op = String.at(string, 1)

      case parts do
        [c, val, to] when length(parts) == 3 ->
          %__MODULE__{
            c: String.to_atom(c),
            op: if(op == "<", do: &Kernel.</2, else: &Kernel.>/2),
            val: String.to_integer(val),
            to: to
          }

        [to] when length(parts) == 1 ->
          %__MODULE__{to: to}
      end
    end

    def apply(%__MODULE__{c: nil, to: to}, _), do: {:halt, to}

    def apply(%__MODULE__{} = rule, %Part{} = part) do
      if rule.op.(hd(Map.get(part, rule.c)), rule.val), do: {:halt, rule.to}, else: {:cont, nil}
    end
  end

  defmodule Workflow do
    def from_input(string) do
      Regex.named_captures(~r/(?<name>\w+){(?<rules>.+)}/, string)
      |> then(fn v ->
        rules =
          v["rules"]
          |> String.split(",")
          |> Enum.map(&Rule.from_input/1)

        {v["name"], rules}
      end)
    end

    def apply(workflow, %Part{} = part) do
      Enum.reduce_while(workflow, nil, fn %Rule{} = rule, _ ->
        Rule.apply(rule, part)
      end)
    end

    def split(workflow),
      do:
        Enum.reverse(workflow)
        |> Enum.split(1)
        |> then(fn {last, rest} -> {hd(last), Enum.reverse(rest)} end)
  end

  @impl Days.Day
  def part_one(input) do
    {workflows, parts} = parse_input(input)
    start = Map.get(workflows, "in")

    Enum.map(parts, fn p -> process(workflows, start, p) end) |> Enum.sum()
  end

  @impl Days.Day
  def part_two(input) do
    {workflows, _} = parse_input(input)

    combos(
      %Part{x: 1..4000, m: 1..4000, a: 1..4000, s: 1..4000},
      workflows,
      "in"
    )
    |> elem(0)
  end

  def parse_input(input) do
    [workflows, parts] = input |> String.split("\n\n", trim: true)

    workflows =
      workflows
      |> String.split("\n", trim: true)
      |> Enum.map(&Workflow.from_input/1)
      |> Enum.into(%{})

    parts = parts |> String.split("\n", trim: true) |> Enum.map(&Part.from_input/1)

    {workflows, parts}
  end

  def process(workflows, workflow, %Part{} = part) do
    case Workflow.apply(workflow, part) do
      "R" -> 0
      "A" -> Part.sum(part)
      w -> process(workflows, Map.get(workflows, w), part)
    end
  end

  def combos(_, _, "R"), do: {0, :none}
  def combos(%Part{} = part, _, "A"), do: {Part.combos(part), :none}

  def combos(%Part{} = part, workflows, name) do
    {last, rest} = Map.get(workflows, name) |> Workflow.split()

    {res, remaining} =
      Enum.reduce(rest, {0, part}, fn %Rule{} = rule, {counts, %Part{} = acc} ->
        {l, r} = Part.split(acc, rule)
        {counts + (combos(l, workflows, rule.to) |> elem(0)), r}
      end)

    {res + (combos(remaining, workflows, last.to) |> elem(0)), :none}
  end
end
