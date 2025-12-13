import day
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub const day = day.Day(part_one: part_one, part_two: part_two)

pub fn part_one(input: String) -> day.DayResult {
  let #(shapes, candidates) = parse(input)

  candidates
  |> list.filter(fn(c) { workable(shapes, c) })
  |> list.length()
  |> day.IntResult()
}

pub fn part_two(_: String) -> day.DayResult {
  0
  |> day.IntResult()
}

type Cand {
  Cand(w: Int, h: Int, tiles: List(Int))
}

fn workable(counts: dict.Dict(Int, Int), candidate: Cand) -> Bool {
  let cand_count =
    candidate.tiles
    |> list.index_fold(0, fn(acc, t, idx) {
      acc + { dict.get(counts, idx) |> result.unwrap(0) } * t
    })

  cand_count <= candidate.w * candidate.h
}

fn parse(input: String) -> #(dict.Dict(Int, Int), List(Cand)) {
  let lines =
    input
    |> string.trim()
    |> string.split("\n\n")

  let assert [candidates, ..shapes] = list.reverse(lines)

  let shapes =
    shapes
    |> list.reverse()
    |> list.index_fold(dict.new(), fn(acc, shape, idx) {
      acc
      |> dict.insert(
        idx,
        shape
          |> string.to_graphemes()
          |> list.fold(0, fn(acc, x) {
            case x {
              "#" -> acc + 1
              _ -> acc
            }
          }),
      )
    })

  let candidates =
    candidates
    |> string.split("\n")
    |> list.fold([], fn(acc, line) {
      let assert Ok(#(dims, tiles)) = string.split_once(line, ":")
      let assert Ok(#(w, h)) = string.split_once(dims, "x")
      let assert Ok(w) = int.parse(w)
      let assert Ok(h) = int.parse(h)
      let tiles =
        tiles
        |> string.trim()
        |> string.split(" ")
        |> list.map(fn(x) {
          let assert Ok(t) = int.parse(x)
          t
        })

      [Cand(w: w, h: h, tiles: tiles), ..acc]
    })

  #(shapes, candidates)
}
