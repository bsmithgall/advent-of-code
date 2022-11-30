use std::collections::BinaryHeap;
use std::collections::HashSet;

pub fn amphipods(skip: bool) {
    if !skip {
        // // part 1 -- requires some rewriting to get the types correct
        // let c = Cave {
        //     hallway: Hallway::new(),
        //     rooms: [
        //         Room {
        //             allowed_type: Amphipod::A,
        //             spots: [Some(Amphipod::B), Some(Amphipod::C)],
        //         },
        //         Room {
        //             allowed_type: Amphipod::B,
        //             spots: [Some(Amphipod::B), Some(Amphipod::A)],
        //         },
        //         Room {
        //             allowed_type: Amphipod::C,
        //             spots: [Some(Amphipod::D), Some(Amphipod::D)],
        //         },
        //         Room {
        //             allowed_type: Amphipod::D,
        //             spots: [Some(Amphipod::A), Some(Amphipod::C)],
        //         },
        //     ],
        // };

        let c = Cave {
            hallway: Hallway::new(),
            rooms: [
                Room {
                    allowed_type: Amphipod::A,
                    spots: [
                        Some(Amphipod::B),
                        Some(Amphipod::D),
                        Some(Amphipod::D),
                        Some(Amphipod::C),
                    ],
                },
                Room {
                    allowed_type: Amphipod::B,
                    spots: [
                        Some(Amphipod::B),
                        Some(Amphipod::C),
                        Some(Amphipod::B),
                        Some(Amphipod::A),
                    ],
                },
                Room {
                    allowed_type: Amphipod::C,
                    spots: [
                        Some(Amphipod::D),
                        Some(Amphipod::B),
                        Some(Amphipod::A),
                        Some(Amphipod::D),
                    ],
                },
                Room {
                    allowed_type: Amphipod::D,
                    spots: [
                        Some(Amphipod::A),
                        Some(Amphipod::A),
                        Some(Amphipod::C),
                        Some(Amphipod::C),
                    ],
                },
            ],
        };

        let shortest_path = calculate_shortest_path(c);
        println!("Shortest path: {}", shortest_path);
    }
}

#[derive(PartialEq, Eq, Debug, Clone, Copy, Hash)]
enum Amphipod {
    A,
    B,
    C,
    D,
}

impl Amphipod {
    fn cost(&self) -> u64 {
        match self {
            Amphipod::A => 1,
            Amphipod::B => 10,
            Amphipod::C => 100,
            Amphipod::D => 1000,
        }
    }
}

#[derive(PartialEq, Eq, Debug, Hash, Clone, Copy)]
struct Room {
    allowed_type: Amphipod,
    spots: [Option<Amphipod>; 4],
}

impl Room {
    fn completed(&self) -> bool {
        self.spots.iter().all(|s| s == &Some(self.allowed_type))
    }

    fn can_accept(&self, a: Amphipod) -> bool {
        if self.allowed_type != a {
            return false;
        }

        self.spots
            .iter()
            .all(|s| s.is_none() || s == &Some(self.allowed_type))
    }

    fn enter(&mut self, a: Amphipod) -> u64 {
        for idx in (0..self.spots.len()).rev() {
            if self.spots[idx].is_none() {
                self.spots[idx] = Some(a);
                return idx as u64 + 1;
            }
        }

        unreachable!()
    }

    fn exit(&mut self) -> Option<(u64, Amphipod)> {
        for idx in 0..self.spots.len() {
            // if we have a non-empty spot...
            if self.spots[idx].is_some() {
                // ...and it or anything further down the line are filled with an incorrect type...
                if self.spots[idx..]
                    .iter()
                    .any(|s| s != &Some(self.allowed_type))
                {
                    // take this one out
                    let a = self.spots[idx].take();
                    return Some((idx as u64 + 1, a.unwrap()));
                } else {
                    return None;
                }
            }
        }
        None
    }
}

#[derive(Debug, PartialEq, Eq, Hash, Clone, Copy)]
struct Hallway {
    tiles: [Option<Amphipod>; 11],
}

impl Hallway {
    fn new() -> Hallway {
        Hallway {
            tiles: [
                None, None, None, None, None, None, None, None, None, None, None,
            ],
        }
    }

    fn steps_from_room_to_room(&self, from: usize, to: usize) -> Option<u64> {
        self.calculate_steps(2 + from * 2, 2 + to * 2, false)
    }

    fn steps_from_tile_to_room(&self, from: usize, to: usize) -> Option<u64> {
        self.calculate_steps(from, 2 + to * 2, false)
    }

    fn steps_from_room_to_tile(&self, from: usize, to: usize) -> Option<u64> {
        self.calculate_steps(2 + from * 2, to, true)
    }

    fn calculate_steps(&self, from: usize, to: usize, to_tile: bool) -> Option<u64> {
        // can't access the tile directly in front of a room
        if to_tile && [2, 4, 6, 8].contains(&to) {
            return None;
        }

        // can't move to yourself
        if from == to {
            return None;
        }

        // Otherwise generate a cost and make the from/to direction consistent
        // so we can check if someone is blocking the way
        let (cost, from, to) = if from < to {
            (to - from, from + 1, to)
        } else {
            (from - to, to, from - 1)
        };

        // can't move if there's someone in the way
        for tile_idx in from..=to {
            if self.tiles[tile_idx].is_some() {
                return None;
            }
        }

        Some(cost as u64)
    }
}

#[derive(Debug, PartialEq, Eq, Hash, Clone, Copy)]
struct Cave {
    rooms: [Room; 4],
    hallway: Hallway,
}

impl Cave {
    fn finished(&self) -> bool {
        self.rooms.iter().all(Room::completed)
    }

    fn generate_possible_moves(&self) -> Option<Vec<(u64, Self)>> {
        if self.finished() {
            return None;
        }

        let mut possible_moves = vec![];

        for room_idx in 0..self.rooms.len() {
            let mut cave = *self;

            // find all moves that go from a hallway tile into a room
            for tile_idx in 0..cave.hallway.tiles.len() {
                let amphipod = if let Some(amphipod) = self.hallway.tiles[tile_idx] {
                    amphipod
                } else {
                    continue;
                };

                if let Some(steps_to_room) =
                    self.hallway.steps_from_tile_to_room(tile_idx, room_idx)
                {
                    if cave.rooms[room_idx].can_accept(amphipod) {
                        let mut new_cave = cave;
                        new_cave.hallway.tiles[tile_idx] = None;
                        let move_in_steps = new_cave.rooms[room_idx].enter(amphipod);
                        possible_moves
                            .push(((steps_to_room + move_in_steps) * amphipod.cost(), new_cave));
                    }
                }
            }

            // find everything that requires moving out of a room...
            let (move_out_steps, amphipod) =
                if let Some((move_out_steps, amphipod)) = cave.rooms[room_idx].exit() {
                    (move_out_steps, amphipod)
                } else {
                    continue;
                };

            // ...and into another room directly
            for destination_idx in 0..self.rooms.len() {
                if room_idx == destination_idx {
                    continue;
                }

                if let Some(room_to_room_steps) = self
                    .hallway
                    .steps_from_room_to_room(room_idx, destination_idx)
                {
                    if cave.rooms[destination_idx].can_accept(amphipod) {
                        let mut new_cave = cave;
                        let move_in_steps = new_cave.rooms[destination_idx].enter(amphipod);
                        possible_moves.push((
                            (room_to_room_steps + move_in_steps + move_out_steps) * amphipod.cost(),
                            new_cave,
                        ))
                    }
                }
            }

            // ...and into a free spot in the hallway
            for tile_idx in 0..cave.hallway.tiles.len() {
                if let Some(to_tile_steps) =
                    self.hallway.steps_from_room_to_tile(room_idx, tile_idx)
                {
                    let mut new_cave = cave;
                    new_cave.hallway.tiles[tile_idx] = Some(amphipod);
                    possible_moves
                        .push(((move_out_steps + to_tile_steps) * amphipod.cost(), new_cave))
                }
            }
        }

        Some(possible_moves)
    }
}

#[derive(Debug, PartialEq, Eq)]
struct CaveState {
    cost: u64,
    cave: Cave,
}

impl Ord for CaveState {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        other.cost.cmp(&self.cost)
    }
}

impl PartialOrd for CaveState {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        Some(self.cmp(other))
    }
}

fn calculate_shortest_path(cave: Cave) -> u64 {
    let mut heap = BinaryHeap::new();
    heap.push(CaveState { cost: 0, cave });

    let mut seen_caves = HashSet::new();

    while let Some(cave_state) = heap.pop() {
        if cave_state.cave.finished() {
            println!("{:?}", cave_state.cave);
            return cave_state.cost;
        }

        let moves = cave_state.cave.generate_possible_moves().unwrap();

        for (cost, cave) in moves {
            if seen_caves.insert(cave) {
                heap.push(CaveState {
                    cost: cave_state.cost + cost,
                    cave,
                })
            }
        }
    }

    unreachable!()
}
