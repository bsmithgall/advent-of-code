import gleam/dict.{type Dict}
import gleam/list
import gleam/string

pub type Point {
  Point(x: Int, y: Int)
}

pub type Grid(a) {
  Grid(w: Int, h: Int, coords: Dict(Point, a))
}

pub fn from_input(input: String, map_fn: fn(String) -> a) -> Grid(a) {
  let lines = input |> string.trim() |> string.split("\n")
  let assert Ok(first) = list.first(lines)

  let points: Dict(Point, a) =
    lines
    |> list.index_fold(dict.new(), fn(acc, row, idy) {
      acc
      |> dict.merge(
        row
        |> string.trim()
        |> string.to_graphemes()
        |> list.map(fn(x) { map_fn(x) })
        |> list.index_fold(dict.new(), fn(row_acc, cell, idx) {
          row_acc |> dict.insert(Point(idx, idy), cell)
        }),
      )
    })

  Grid(
    { first |> string.to_graphemes() |> list.length() } - 1,
    list.length(lines) - 1,
    points,
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
