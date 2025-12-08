import day
import gleam/dict
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/string

pub const day = day.Day(part_one: part_one, part_two: part_two)

pub fn part_one(input: String) -> day.DayResult {
  part_one_inner(input, 1000)
}

// test has a lower connection limit
pub fn part_one_inner(input: String, limit: Int) -> day.DayResult {
  let #(boxes, pairs) = parse(input)

  let init = boxes |> list.map(fn(x) { #(x, x) }) |> dict.from_list()
  let merged =
    pairs
    |> list.take(limit)
    |> list.fold(init, fn(acc, pair) { acc |> union(pair) })

  boxes
  |> list.map(fn(x) { find(merged, x) })
  |> list.fold(dict.new(), fn(acc, x) {
    acc
    |> dict.upsert(x, fn(x) {
      case x {
        option.Some(i) -> i + 1
        option.None -> 1
      }
    })
  })
  |> dict.values()
  |> list.sort(int.compare)
  |> list.reverse()
  |> list.take(3)
  |> list.fold(1, fn(acc, x) { acc * x })
  |> day.IntResult()
}

pub fn part_two(input: String) -> day.DayResult {
  let #(boxes, pairs) = parse(input)

  let init = boxes |> list.map(fn(x) { #(x, x) }) |> dict.from_list()

  let last_pair = find_last_pair(list.length(boxes) - 1, init, pairs)

  day.IntResult(last_pair.l.x * last_pair.r.x)
}

fn find_last_pair(
  remaining: Int,
  merged: dict.Dict(Box, Box),
  pairs: List(Pair),
) -> Pair {
  let assert [p, ..rest] = pairs
  case find(merged, p.l) == find(merged, p.r) {
    True -> find_last_pair(remaining, merged, rest)
    False -> {
      case remaining {
        1 -> p
        _ -> find_last_pair(remaining - 1, union(merged, p), rest)
      }
    }
  }
}

type Box {
  Box(x: Int, y: Int, z: Int)
}

fn dist(a: Box, b: Box) -> Float {
  let assert Ok(x) = { a.x - b.x } |> int.power(2.0)
  let assert Ok(y) = { a.y - b.y } |> int.power(2.0)
  let assert Ok(z) = { a.z - b.z } |> int.power(2.0)

  let assert Ok(dist) = float.square_root(x +. y +. z)
  dist
}

type Pair {
  Pair(l: Box, r: Box, dist: Float)
}

fn parse(input: String) -> #(List(Box), List(Pair)) {
  let boxes: List(Box) =
    input
    |> string.split("\n")
    |> list.map(fn(line) {
      case line |> string.split(",") {
        [] -> panic
        [x, y, z] -> {
          let assert Ok(x) = int.parse(x)
          let assert Ok(y) = int.parse(y)
          let assert Ok(z) = int.parse(z)

          Box(x, y, z)
        }
        _ -> panic
      }
    })

  let pairs: List(Pair) =
    boxes
    |> list.combination_pairs()
    |> list.map(fn(boxes) {
      let #(l, r) = boxes
      Pair(l, r, dist(l, r))
    })
    |> list.sort(fn(l, r) { float.compare(l.dist, r.dist) })

  #(boxes, pairs)
}

fn union(acc: dict.Dict(Box, Box), p: Pair) -> dict.Dict(Box, Box) {
  let l_root = find(acc, p.l)
  let r_root = find(acc, p.r)

  dict.insert(acc, l_root, r_root)
}

fn find(acc: dict.Dict(a, a), x: a) -> a {
  case dict.get(acc, x) {
    Error(_) -> panic
    Ok(p) if x == p -> x
    Ok(p) -> find(acc, p)
  }
}
