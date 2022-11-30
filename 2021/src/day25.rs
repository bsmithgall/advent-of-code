use std::collections::HashMap;
use std::fmt::{Debug, Write};

pub fn cucumbers(skip: bool) {
    if !skip {
        let mut sea_floor = SeaFloor::from_input(include_str!("inputs/day-25.txt"));

        let steps_til_stopped = step_til_stop(&mut sea_floor);
        println!("Steps til stopped: {}", steps_til_stopped);
    }
}

fn step_til_stop(sea_floor: &mut SeaFloor) -> usize {
    let mut step = 1;

    while sea_floor.step() > 0 {
        step += 1;
    }

    step
}

#[derive(PartialEq, Eq)]
enum Square {
    // east-facing cucumber (>)
    E,
    // south-facing cucumber (v)
    S,
    // empty spot (.)
    Empty,
}

impl Square {
    fn from_char(c: char) -> Square {
        match c {
            '>' => Self::E,
            'v' => Self::S,
            '.' => Self::Empty,
            _ => unreachable!(),
        }
    }
}

impl Debug for Square {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::E => f.write_char('>'),
            Self::S => f.write_char('v'),
            Self::Empty => f.write_char('.'),
        }
    }
}

struct SeaFloor {
    height: isize,
    width: isize,
    map: HashMap<(isize, isize), Square>,
    eastern_herd: Vec<(isize, isize)>,
    southern_herd: Vec<(isize, isize)>,
}

impl SeaFloor {
    fn from_input(input: &str) -> SeaFloor {
        let height = input.lines().count() as isize;
        let mut width = 0;

        let map: HashMap<(isize, isize), Square> = input
            .lines()
            .enumerate()
            .flat_map(|(idy, line)| {
                if width == 0 {
                    width = line.trim().chars().count() as isize;
                }
                line.trim().chars().enumerate().map(move |(idx, c)| {
                    let x = idx.try_into().unwrap();
                    let y = idy.try_into().unwrap();
                    ((x, y), Square::from_char(c))
                })
            })
            .collect();

        SeaFloor {
            height,
            width,
            eastern_herd: map
                .iter()
                .filter_map(|((x, y), square)| match square {
                    Square::E => Some((*x, *y)),
                    _ => None,
                })
                .collect(),
            southern_herd: map
                .iter()
                .filter_map(|((x, y), square)| match square {
                    Square::S => Some((*x, *y)),
                    _ => None,
                })
                .collect(),
            map,
        }
    }

    /// Moves the eastern-facing and then the southern-facing cucumbers per their respective
    /// methods below. Returns the total number of cucumbers that moved.
    fn step(&mut self) -> usize {
        let mut total = 0;
        total += self.move_eastern_herd();
        total += self.move_southern_herd();
        total
    }

    /// Figures out which eastern-facing cucumbers need to move, and then updates the map
    /// and the herd with the new coordinations. Returns the total number of cucumbers that moved
    /// in this step
    fn move_eastern_herd(&mut self) -> usize {
        // get the movable eastern-facing cucumbers
        let mut moveable_eastern = Vec::new();
        let mut new_eastern_herd = Vec::new();
        while self.eastern_herd.len() > 0 {
            if self.right_square_empty(self.eastern_herd[0]) {
                moveable_eastern.push(self.eastern_herd.remove(0));
            } else {
                new_eastern_herd.push(self.eastern_herd.remove(0));
            }
        }

        moveable_eastern.iter().for_each(|(x, y)| {
            // move the cucumber to the right in the map
            self.map
                .insert((self.next_x_with_wraparound(*x), *y), Square::E);
            // mark the current square they used to be in as empty
            self.map.insert((*x, *y), Square::Empty);
            // add their new location to the herd map
            new_eastern_herd.push((self.next_x_with_wraparound(*x), *y));
        });

        self.eastern_herd = new_eastern_herd;
        moveable_eastern.len()
    }

    /// Figures out which southern-facing cucumbers need to move, and then updates the map
    /// and the herd with the new coordinations. Returns the total number of cucumbers that moved
    /// in this step
    fn move_southern_herd(&mut self) -> usize {
        // get the movable southern-facing cucumbers
        let mut moveable_southern = Vec::new();
        let mut new_southern_herd = Vec::new();
        while self.southern_herd.len() > 0 {
            if self.down_square_empty(self.southern_herd[0]) {
                moveable_southern.push(self.southern_herd.remove(0));
            } else {
                new_southern_herd.push(self.southern_herd.remove(0));
            }
        }

        moveable_southern.iter().for_each(|(x, y)| {
            // move the cucumber to the down in the map
            self.map
                .insert((*x, self.next_y_with_wraparound(*y)), Square::S);
            // mark the current square they used to be in as empty
            self.map.insert((*x, *y), Square::Empty);
            // add their new location to the herd map
            new_southern_herd.push((*x, self.next_y_with_wraparound(*y)))
        });

        self.southern_herd = new_southern_herd;
        moveable_southern.len()
    }

    fn right_square_empty(&self, square: (isize, isize)) -> bool {
        let (x, y) = square;
        match self.map.get(&(self.next_x_with_wraparound(x), y)).unwrap() {
            Square::Empty => true,
            _ => false,
        }
    }

    fn down_square_empty(&self, square: (isize, isize)) -> bool {
        let (x, y) = square;
        match self.map.get(&(x, self.next_y_with_wraparound(y))).unwrap() {
            Square::Empty => true,
            _ => false,
        }
    }

    fn next_x_with_wraparound(&self, x: isize) -> isize {
        if x == self.width - 1 {
            0
        } else {
            x + 1
        }
    }

    fn next_y_with_wraparound(&self, y: isize) -> isize {
        if y == self.height - 1 {
            0
        } else {
            y + 1
        }
    }
}

impl Debug for SeaFloor {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        for y in 0..self.height {
            writeln!(f)?;
            for x in 0..self.width {
                write!(
                    f,
                    "{:?}",
                    self.map
                        .get(&(x, y))
                        .expect(format!("Could not find a value for ({}, {})", x, y).as_str())
                )?;
            }
        }

        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_sample_stop() {
        let mut sea_floor = SeaFloor::from_input(
            "v...>>.vv>
        .vv>>.vv..
        >>.>v>...v
        >>v>>.>.v.
        v>v.vv.v..
        >.>>..v...
        .vv..>.>v.
        v.v..>>v.v
        ....v..v.>",
        );
        let steps = step_til_stop(&mut sea_floor);

        assert_eq!(steps, 58);
    }
}
