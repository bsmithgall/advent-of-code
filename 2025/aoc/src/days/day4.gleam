import day
import gleam/dict
import gleam/list
import gleam/pair
import grid

pub const day = day.Day(part_one: part_one, part_two: part_two)

pub fn part_one(input: String) -> day.DayResult {
  grid.from_input(input, fn(x) { x })
  |> accessible
  |> list.length()
  |> day.IntResult()
}

pub fn part_two(input: String) -> day.DayResult {
  grid.from_input(input, fn(x) { x })
  |> reduce(0)
  |> pair.second()
  |> day.IntResult()
}

fn reduce(floor: grid.Grid(String), acc: Int) -> #(grid.Grid(String), Int) {
  let newly_accessible =
    floor |> accessible() |> list.map(fn(a) { #(a, ".") }) |> dict.from_list()

  case newly_accessible |> dict.size() {
    0 -> #(floor, acc)
    n ->
      reduce(
        grid.Grid(
          w: floor.w,
          h: floor.h,
          coords: dict.merge(floor.coords, newly_accessible),
        ),
        acc + n,
      )
  }
}

fn accessible(floor: grid.Grid(String)) -> List(grid.Point) {
  floor.coords
  |> dict.filter(fn(_, val) { val == "@" })
  |> dict.filter(fn(point, _) {
    grid.neighbors(floor, point)
    |> list.filter(fn(n) { n.1 == "@" })
    |> list.length()
    < 4
  })
  |> dict.keys
}
