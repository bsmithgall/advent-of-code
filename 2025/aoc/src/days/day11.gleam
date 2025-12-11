import day
import gleam/dict
import gleam/list
import gleam/option
import gleam/set.{type Set}
import gleam/string

pub const day = day.Day(part_one: part_one, part_two: part_two)

pub fn part_one(input: String) -> day.DayResult {
  input
  |> parse()
  |> count_to_out()
  |> day.IntResult()
}

pub fn part_two(input: String) -> day.DayResult {
  input
  |> parse()
  |> count_paths_through(["dac", "fft"])
  |> day.IntResult()
}

type Node {
  Node(name: String, in: Set(String), out: Set(String))
}

type Nodes =
  dict.Dict(String, Node)

fn parse(input: String) -> Nodes {
  input
  |> string.trim()
  |> string.split("\n")
  |> list.fold(dict.new(), fn(acc: Nodes, line) {
    let assert [name, outs] = string.split(line, ":")
    let outs = outs |> string.trim() |> string.split(" ") |> set.from_list()

    let acc =
      acc
      |> dict.upsert(name, fn(exists) {
        case exists {
          option.Some(node) -> Node(name: node.name, in: node.in, out: outs)
          option.None -> Node(name: name, in: set.new(), out: outs)
        }
      })

    outs
    |> set.fold(acc, fn(acc, out_name) {
      acc
      |> dict.upsert(out_name, fn(exists) {
        case exists {
          option.Some(node) ->
            Node(name: node.name, in: set.insert(node.in, name), out: node.out)
          option.None ->
            Node(name: out_name, in: set.from_list([name]), out: set.new())
        }
      })
    })
  })
}

fn count_to_out(nodes: Nodes) {
  let assert Ok(start) = dict.get(nodes, "you")
  count_to_out_loop(nodes, 0, start.out |> set.to_list())
}

fn count_to_out_loop(nodes: Nodes, ct: Int, stack: List(String)) -> Int {
  case stack {
    [] -> ct
    [head, ..rest] -> {
      let assert Ok(next) = dict.get(nodes, head)
      case head {
        "out" -> count_to_out_loop(nodes, ct + 1, rest)
        _ ->
          count_to_out_loop(
            nodes,
            ct,
            list.append(rest, next.out |> set.to_list()),
          )
      }
    }
  }
}

type CacheCount =
  dict.Dict(#(String, Set(String)), Int)

fn count_paths_through(nodes: Nodes, through: List(String)) {
  let assert Ok(start) = dict.get(nodes, "svr")

  let #(count, _) =
    start.out
    |> set.fold(#(0, dict.new()), fn(acc, node) {
      let #(total, cache) = acc
      let #(new_count, cache) =
        count_paths_through_loop(
          nodes,
          set.new(),
          through |> set.from_list(),
          node,
          cache,
        )
      #(total + new_count, cache)
    })

  count
}

fn count_paths_through_loop(
  nodes: Nodes,
  visited: Set(String),
  needed: Set(String),
  at: String,
  cache: CacheCount,
) -> #(Int, CacheCount) {
  case at {
    "out" -> {
      case set.is_empty(needed) {
        True -> #(1, cache)
        False -> #(0, cache)
      }
    }
    _ -> {
      case set.contains(visited, at) {
        True -> #(0, cache)
        False -> {
          let cache_key = #(at, needed)
          case dict.get(cache, cache_key) {
            Ok(ct) -> #(ct, cache)
            Error(Nil) -> {
              let assert Ok(next) = dict.get(nodes, at)

              let #(count, updated_cache) =
                next.out
                |> set.fold(#(0, cache), fn(acc, node) {
                  let #(total, curr_cache) = acc
                  let #(new_count, cache) =
                    count_paths_through_loop(
                      nodes,
                      set.insert(visited, at),
                      set.delete(needed, at),
                      node,
                      curr_cache,
                    )
                  #(total + new_count, cache)
                })

              #(count, dict.insert(updated_cache, cache_key, count))
            }
          }
        }
      }
    }
  }
}
