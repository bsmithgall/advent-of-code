import day
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import grid

pub const day = day.Day(part_one: part_one, part_two: part_two)

pub fn part_one(input: String) -> day.DayResult {
  let assert Ok(v) =
    parse(input)
    |> list.combination_pairs()
    |> list.map(from_points)
    |> list.map(area)
    |> list.sort(int.compare)
    |> list.reverse()
    |> list.first

  v |> day.IntResult()
}

pub fn part_two(input: String) -> day.DayResult {
  let points = parse(input)

  let polygon: List(Edge) =
    points |> list.window_by_2() |> list.map(from_points)

  let assert Ok(first_point) = list.first(points)
  let assert Ok(last_point) = list.last(points)
  let closing_edge = Edge(last_point, first_point)
  let polygon = list.append(polygon, [closing_edge])

  points
  |> list.combination_pairs()
  |> list.map(from_points)
  |> find_max_area(polygon, 0)
  |> day.IntResult()
}

fn find_max_area(
  candidates: List(Rectangle),
  polygon: List(Edge),
  max_area: Int,
) -> Int {
  case candidates {
    [] -> max_area
    [candidate, ..rest] -> {
      case
        corners_are_inside(candidate, polygon)
        && no_interior_overlap(candidate, polygon)
      {
        True -> find_max_area(rest, polygon, int.max(max_area, area(candidate)))
        False -> find_max_area(rest, polygon, max_area)
      }
    }
  }
}

fn corners_are_inside(candidate: Rectangle, polygon: List(Edge)) -> Bool {
  candidate
  |> corners()
  |> list.all(fn(c) { point_is_inside_or_on(c, polygon, 0) })
}

fn point_is_inside_or_on(
  point: grid.Point,
  polygon: List(Edge),
  crossings: Int,
) -> Bool {
  case polygon {
    [] -> crossings % 2 == 1
    [edge, ..rest] -> {
      case point_on_edge(point, edge) {
        True -> True
        False -> {
          let y_crossing = {
            { edge.l.y <= point.y && edge.r.y > point.y }
            || { edge.r.y <= point.y && edge.l.y > point.y }
          }
          case y_crossing {
            False -> point_is_inside_or_on(point, rest, crossings)
            True -> {
              let x_intersection =
                edge.l.x
                + { point.y - edge.l.y }
                * { edge.r.x - edge.l.x }
                / { edge.r.y - edge.l.y }
              case x_intersection {
                x if x == point.x -> True
                x if x > point.x ->
                  point_is_inside_or_on(point, rest, crossings + 1)
                _ -> point_is_inside_or_on(point, rest, crossings)
              }
            }
          }
        }
      }
    }
  }
}

fn point_on_edge(point: grid.Point, edge: Edge) -> Bool {
  let min_x = int.min(edge.l.x, edge.r.x)
  let max_x = int.max(edge.l.x, edge.r.x)
  let min_y = int.min(edge.l.y, edge.r.y)
  let max_y = int.max(edge.l.y, edge.r.y)

  point.x >= min_x
  && point.x <= max_x
  && point.y >= min_y
  && point.y <= max_y
  && { point.x == edge.l.x || point.y == edge.l.y }
}

fn no_interior_overlap(candidate: Rectangle, polygon: List(Edge)) -> Bool {
  !list.any(polygon, fn(edge) {
    edge_intersects_rectangle_interior(edge, candidate)
  })
}

fn edge_intersects_rectangle_interior(edge: Edge, rect: Rectangle) -> Bool {
  let rect_min_x = int.min(rect.l.x, rect.r.x)
  let rect_max_x = int.max(rect.l.x, rect.r.x)
  let rect_min_y = int.min(rect.l.y, rect.r.y)
  let rect_max_y = int.max(rect.l.y, rect.r.y)

  let edge_min_x = int.min(edge.l.x, edge.r.x)
  let edge_max_x = int.max(edge.l.x, edge.r.x)
  let edge_min_y = int.min(edge.l.y, edge.r.y)
  let edge_max_y = int.max(edge.l.y, edge.r.y)

  let horizontal_intersects = case edge.l.y == edge.r.y {
    True -> {
      edge.l.y > rect_min_y
      && edge.l.y < rect_max_y
      && edge_max_x > rect_min_x
      && edge_min_x < rect_max_x
    }
    False -> False
  }

  let vertical_intersects = case edge.l.x == edge.r.x {
    True -> {
      edge.l.x > rect_min_x
      && edge.l.x < rect_max_x
      && edge_max_y > rect_min_y
      && edge_min_y < rect_max_y
    }
    False -> False
  }

  horizontal_intersects || vertical_intersects
}

type Edge {
  Edge(l: grid.Point, r: grid.Point)
}

type Rectangle =
  Edge

fn from_points(points: #(grid.Point, grid.Point)) -> Edge {
  Edge(points.0, points.1)
}

fn corners(rect: Rectangle) -> List(grid.Point) {
  [
    rect.l,
    rect.r,
    grid.Point(rect.l.x, rect.r.y),
    grid.Point(rect.r.x, rect.l.y),
  ]
}

fn area(rect: Rectangle) -> Int {
  let w = { rect.r.x - rect.l.x } |> int.absolute_value |> int.add(1)
  let l = { rect.r.y - rect.l.y } |> int.absolute_value |> int.add(1)
  w * l
}

fn parse(input: String) -> List(grid.Point) {
  input
  |> string.trim()
  |> string.split("\n")
  |> list.map(fn(x) {
    let assert [l, r] =
      string.split(x, ",")
      |> list.map(fn(p) { int.parse(p) |> result.unwrap(0) })
    grid.Point(l, r)
  })
}
