import day
import gleam/dict
import gleam/list
import gleam/option
import gleam/string
import grid

pub const day = day.Day(part_one: part_one, part_two: part_two)

pub fn part_one(input: String) -> day.DayResult {
  let beams =
    input
    |> grid.from_input(string.to_graphemes, fn(x) { x })

  let start = beams |> grid.find_by_value("S")
  let splitters =
    beams.coords |> dict.filter(fn(_, v) { v == "^" }) |> dict.keys

  split_beams(beams, splitters, start, 0, 0)
  |> day.IntResult()
}

pub fn part_two(input: String) -> day.DayResult {
  let beams =
    input
    |> grid.from_input(string.to_graphemes, fn(x) { x })

  let start =
    beams
    |> grid.find_by_value("S")
    |> list.map(fn(x) { #(x, 1) })
    |> dict.from_list()

  let splitters =
    beams.coords
    |> dict.filter(fn(_, v) { v == "^" })
    |> dict.keys

  count_timelines(beams, splitters, start, 0)
  |> day.IntResult()
}

fn split_beams(
  grid: grid.Grid(String),
  splitters: List(grid.Point),
  beams: List(grid.Point),
  splits: Int,
  row: Int,
) -> Int {
  case row > grid.h {
    True -> splits
    False -> {
      let in_row = splitters |> list.filter(fn(pt) { pt.y == row })

      let #(new_beams, new_splits) =
        beams
        |> list.fold(#(beams, 0), fn(acc, beam) {
          let #(new_beams, new_splits) = acc
          case in_row |> list.contains(beam) {
            True -> #(
              [
                grid.Point(beam.x - 1, beam.y + 1),
                grid.Point(beam.x + 1, beam.y + 1),
                ..new_beams
              ],
              new_splits + 1,
            )
            False -> #(
              [grid.Point(beam.x, beam.y + 1), ..new_beams],
              new_splits,
            )
          }
        })

      split_beams(
        grid,
        splitters,
        new_beams |> list.unique(),
        splits + new_splits,
        row + 1,
      )
    }
  }
}

fn count_timelines(
  grid: grid.Grid(String),
  splitters: List(grid.Point),
  beams: dict.Dict(grid.Point, Int),
  row: Int,
) -> Int {
  case row > grid.h {
    True -> beams |> dict.values() |> list.fold(0, fn(acc, x) { acc + x })
    False -> {
      let in_row = splitters |> list.filter(fn(pt) { pt.y == row })

      beams
      |> dict.fold(dict.new(), fn(acc, beam, ct) {
        case in_row |> list.contains(beam) {
          True ->
            acc
            |> upsert_beam(grid.Point(beam.x - 1, beam.y + 1), ct)
            |> upsert_beam(grid.Point(beam.x + 1, beam.y + 1), ct)
          False -> acc |> upsert_beam(grid.Point(beam.x, beam.y + 1), ct)
        }
      })
      |> count_timelines(grid, splitters, _, row + 1)
    }
  }
}

fn upsert_beam(
  beams: dict.Dict(grid.Point, Int),
  point: grid.Point,
  current_ct: Int,
) {
  beams
  |> dict.upsert(point, fn(exists) {
    case exists {
      option.Some(n) -> n + current_ct
      option.None -> current_ct
    }
  })
}
