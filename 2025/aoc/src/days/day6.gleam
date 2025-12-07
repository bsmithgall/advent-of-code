import day
import gleam/dict
import gleam/int
import gleam/list
import gleam/pair
import gleam/string
import grid
import util

pub const day = day.Day(part_one: part_one, part_two: part_two)

pub fn part_one(input: String) -> day.DayResult {
  let #(grid, ops) = parse(input)

  column_sum(0, 0, grid, ops)
  |> day.IntResult()
}

pub fn part_two(input: String) -> day.DayResult {
  let #(grid, ops) = parse(input)

  column_cross_sum(0, 0, grid, ops)
  |> day.IntResult()
}

fn column_sum(
  acc: Int,
  col: Int,
  in: grid.Grid(#(Int, Align)),
  ops: dict.Dict(Int, Op),
) -> Int {
  case col > in.w {
    True -> acc
    False -> {
      let assert Ok(op) = dict.get(ops, col)
      let val_for_col =
        grid.get_in_column(in, col)
        |> list.map(fn(pair) { pair.0 })
        |> op_apply(op, _)

      column_sum(acc + val_for_col, col + 1, in, ops)
    }
  }
}

fn column_cross_sum(
  acc: Int,
  col: Int,
  in: grid.Grid(#(Int, Align)),
  ops: dict.Dict(Int, Op),
) -> Int {
  case col > in.w {
    True -> acc
    False -> {
      let assert Ok(op) = dict.get(ops, col)
      let column = grid.get_in_column(in, col) |> list.reverse()

      let val_for_col =
        column
        |> to_grid()
        |> colwise_apply(op, _)

      column_cross_sum(acc + val_for_col, col + 1, in, ops)
    }
  }
}

type Op {
  Add
  Mult
}

type Align {
  L
  R
}

fn op_apply(op: Op, vals: List(Int)) {
  case op {
    Add -> vals |> int.sum()
    Mult -> vals |> list.fold(1, int.multiply)
  }
}

fn colwise_apply(op: Op, inner_grid: grid.Grid(Int)) -> Int {
  let init = case op {
    Add -> 0
    Mult -> 1
  }

  colwise_apply_loop(init, 0, inner_grid, op)
}

fn colwise_apply_loop(acc: Int, col: Int, in: grid.Grid(Int), op: Op) -> Int {
  case col > in.w {
    True -> acc
    False -> {
      let next_number =
        grid.get_in_column(in, col) |> list.reverse() |> undigits()

      let acc = case op {
        Add -> acc + next_number
        Mult -> acc * next_number
      }

      colwise_apply_loop(acc, col + 1, in, op)
    }
  }
}

fn to_grid(in: List(#(Int, Align))) -> grid.Grid(Int) {
  let as_digits =
    in
    |> list.map(fn(pair) {
      let #(num, align) = pair
      let assert Ok(digits) = util.digits(num, 10)
      #(digits, align)
    })

  let assert Ok(size) =
    as_digits
    |> list.map(fn(pair) { list.length(pair.0) })
    |> list.max(int.compare)

  as_digits
  |> list.map(fn(pair) {
    let #(digits, align) = pair
    case align {
      R -> left_pad(digits, size)
      L -> right_pad(digits, size)
    }
  })
  |> grid.from_list()
}

fn left_pad(acc: List(Int), size: Int) -> List(Int) {
  case list.length(acc) == size {
    True -> acc
    False -> left_pad([0, ..acc], size)
  }
}

fn right_pad(acc: List(Int), size: Int) -> List(Int) {
  case list.length(acc) == size {
    True -> acc
    False -> right_pad(list.append(acc, [0]), size)
  }
}

fn parse(input: String) -> #(grid.Grid(#(Int, Align)), dict.Dict(Int, Op)) {
  case input |> string.split("\n") |> list.reverse() {
    [] -> panic
    [ops, ..rest] -> {
      let ops: dict.Dict(Int, #(Int, Op)) =
        ops
        |> string.to_graphemes()
        |> list.index_fold(#([], 0), fn(acc, item, idx) {
          let #(ops, op_idx) = acc
          case item {
            "+" -> #([#(idx, #(op_idx, Add)), ..ops], op_idx + 1)
            "*" -> #([#(idx, #(op_idx, Mult)), ..ops], op_idx + 1)
            _ -> acc
          }
        })
        |> pair.first
        |> dict.from_list()

      let sorted_op_positions =
        ops
        |> dict.to_list()
        |> list.map(fn(item) {
          let #(char_pos, #(col_idx, _op)) = item
          #(char_pos, col_idx)
        })
        |> list.sort(fn(a, b) { int.compare(a.1, b.1) })
        |> list.map(pair.first)

      let digits =
        rest
        |> list.reverse()
        |> list.map(fn(line) {
          sorted_op_positions
          |> list.map(fn(pos) {
            case string.slice(line, pos, 1) {
              " " | "" -> R
              _ -> L
            }
          })
          |> list.zip(
            line
            |> string.trim()
            |> string.split(" ")
            |> list.filter(fn(s) { s != "" }),
          )
          |> list.map(fn(pair) {
            let #(align, num_str) = pair
            let assert Ok(num) = int.parse(num_str)
            #(num, align)
          })
        })
        |> grid.from_list()

      assert digits.w == dict.size(ops) - 1

      #(digits, dict.values(ops) |> dict.from_list())
    }
  }
}

pub fn undigits(numbers: List(Int)) -> Int {
  undigits_loop(numbers, 10, 0)
}

// input checked: there are no zeroes in Cephalopod math!
fn undigits_loop(numbers: List(Int), base: Int, acc: Int) -> Int {
  case numbers {
    [] -> acc
    [digit, ..rest] if digit == 0 -> undigits_loop(rest, base, acc)
    [digit, ..rest] -> undigits_loop(rest, base, acc * base + digit)
  }
}
