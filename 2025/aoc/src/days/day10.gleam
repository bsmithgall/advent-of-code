import day
import gleam/bool
import gleam/dict
import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string
import tinyqueue.{type Queue}

pub const day = day.Day(part_one: part_one, part_two: part_two)

pub fn part_one(input: String) -> day.DayResult {
  input
  |> parse()
  |> list.map(fn(m) {
    let stack =
      m.buttons
      |> list.map(fn(x) { init(m.diagram) |> flip(x) })
      |> list.map(fn(x) { #(x, 1) })
    let queue = tinyqueue.new() |> tinyqueue.push_list(stack)
    get_running(m, queue, set.new())
  })
  |> int.sum()
  |> day.IntResult
}

pub fn part_two(_: String) -> day.DayResult {
  0 |> day.IntResult
}

type Diagram =
  dict.Dict(Int, Bool)

type Button =
  List(Int)

type Machine {
  Machine(diagram: Diagram, buttons: List(Button))
}

fn get_running(
  machine: Machine,
  stack: Queue(#(Diagram, Int)),
  visited: Set(Diagram),
) -> Int {
  case tinyqueue.pop(stack) {
    Ok(#(next, queue)) -> {
      let #(next, presses) = next
      case set.contains(visited, next), next == machine.diagram {
        True, _ -> get_running(machine, queue, visited)
        _, True -> presses
        _, False -> {
          get_running(
            machine,
            machine.buttons
              |> list.map(fn(x) { #(flip(next, x), presses + 1) })
              |> tinyqueue.push_list(queue, _),
            set.insert(visited, next),
          )
        }
      }
    }
    _ -> panic
  }
}

fn init(state: Diagram) -> Diagram {
  state
  |> dict.keys()
  |> list.fold(dict.new(), fn(acc, k) { dict.insert(acc, k, False) })
}

fn flip(state: Diagram, buttons: Button) -> Diagram {
  let new =
    buttons
    |> list.map(fn(x) {
      let assert Ok(current) = dict.get(state, x)
      #(x, bool.negate(current))
    })
    |> dict.from_list()

  dict.merge(state, new)
}

fn parse(input: String) -> List(Machine) {
  input
  |> string.trim()
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert Ok(#(diagram, rest)) = string.split_once(line, " ")
    let diagram =
      diagram
      |> string.drop_start(1)
      |> string.drop_end(1)
      |> string.to_graphemes()
      |> list.index_fold(dict.new(), fn(acc, k, idx) {
        acc
        |> dict.insert(idx, case k {
          "." -> False
          "#" -> True
          _ -> panic
        })
      })

    let assert Ok(#(buttons, _)) = string.split_once(rest, "{")
    let buttons =
      buttons
      |> string.trim_end()
      |> string.split(" ")
      |> list.map(fn(button) {
        button
        |> string.to_graphemes()
        |> list.fold([], fn(acc, c) {
          case int.parse(c) {
            Ok(r) -> [r, ..acc]
            Error(_) -> acc
          }
        })
      })

    Machine(diagram, buttons)
  })
}
