import gleam/dict.{type Dict}
import gleam/list
import gleam/string

pub type Point {
  Point(x: Int, y: Int)
}

pub type Grid(a) {
  Grid(w: Int, h: Int, coords: Dict(Point, a))
}

pub fn from_input(
  input: String,
  split_fn: fn(String) -> List(String),
  map_fn: fn(String) -> a,
) -> Grid(a) {
  let lines = input |> string.split("\n")
  let assert Ok(first) = list.first(lines)

  let points: Dict(Point, a) =
    lines
    |> list.index_fold(dict.new(), fn(acc, row, idy) {
      acc
      |> dict.merge(
        row
        |> split_fn
        |> list.map(fn(x) { map_fn(x) })
        |> list.index_fold(dict.new(), fn(row_acc, cell, idx) {
          row_acc |> dict.insert(Point(idx, idy), cell)
        }),
      )
    })

  Grid(
    w: { first |> split_fn() |> list.length() },
    h: list.length(lines) - 1,
    coords: points,
  )
}

pub fn from_list(input: List(List(a))) -> Grid(a) {
  let assert Ok(first) = list.first(input)
  Grid(
    w: list.length(first) - 1,
    h: list.length(input) - 1,
    coords: input
      |> list.index_fold(dict.new(), fn(acc, row, idy) {
        acc
        |> dict.merge(
          row
          |> list.index_fold(dict.new(), fn(row_acc, cell, idx) {
            row_acc |> dict.insert(Point(idx, idy), cell)
          }),
        )
      }),
  )
}

pub fn neighbors(grid: Grid(a), point: Point) -> List(#(Point, a)) {
  [
    Point(point.x + 1, point.y + 1),
    Point(point.x + 1, point.y - 1),
    Point(point.x + 1, point.y),
    Point(point.x - 1, point.y + 1),
    Point(point.x - 1, point.y - 1),
    Point(point.x - 1, point.y),
    Point(point.x, point.y + 1),
    Point(point.x, point.y - 1),
  ]
  |> list.filter_map(fn(pt) {
    let res = dict.get(grid.coords, pt)

    case res {
      Ok(res) -> Ok(#(pt, res))
      _ -> Error("")
    }
  })
}

pub fn get_in_column(grid: Grid(a), col: Int) -> List(a) {
  get_in_column_loop([], 0, grid, col)
}

fn get_in_column_loop(
  acc: List(a),
  idx: Int,
  grid: Grid(a),
  col: Int,
) -> List(a) {
  case idx > grid.h {
    True -> acc
    False -> {
      let val = case dict.get(grid.coords, Point(col, idx)) {
        Ok(val) -> val
        Error(Nil) -> panic
      }
      get_in_column_loop([val, ..acc], idx + 1, grid, col)
    }
  }
}

pub fn find_by_value(grid: Grid(a), val: a) -> List(Point) {
  grid.coords |> dict.filter(fn(_, v) { val == v }) |> dict.keys
}
