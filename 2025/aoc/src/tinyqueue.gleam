import gleam/list

pub type Queue(a) {
  Queue(front: List(a), back: List(a))
}

pub fn new() -> Queue(a) {
  Queue([], [])
}

pub fn push(q: Queue(a), item: a) -> Queue(a) {
  Queue(..q, back: [item, ..q.back])
}

pub fn push_list(q: Queue(a), items: List(a)) -> Queue(a) {
  items |> list.fold(q, fn(acc, item) { acc |> push(item) })
}

pub fn pop(q: Queue(a)) -> Result(#(a, Queue(a)), Nil) {
  case q.front, q.back {
    [], [] -> Error(Nil)
    [first_front, ..rest], back -> Ok(#(first_front, Queue(rest, back)))
    [], back -> {
      case list.reverse(back) {
        [] -> Error(Nil)
        [first, ..rest] -> Ok(#(first, Queue(rest, [])))
      }
    }
  }
}
