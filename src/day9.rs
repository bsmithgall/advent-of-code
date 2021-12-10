use std::convert::identity;
use std::{collections::HashMap, collections::HashSet, collections::VecDeque};

pub fn smoke_basin(skip: bool) {
    if !skip {
        let lava_map: LavaMap = LavaMap::from_input(include_str!("inputs/day-9.txt"));

        let low_points = lava_map.get_low_points();

        println!(
            "Sum of low points: {}",
            low_points.iter().map(|c| c.risk_level()).sum::<u32>()
        );

        let mut basins: Vec<usize> = low_points
            .iter()
            .map(|low_point| lava_map.build_basin(low_point))
            .map(|basin| basin.len())
            .collect::<Vec<usize>>();

        basins.sort_by(|a, b| b.cmp(a));

        println!(
            "Size of biggest three basins: {}",
            basins
                .get(0..3)
                .expect("Oh no!")
                .iter()
                .fold(1, |acc, f| acc * f)
        );
    }
}

#[derive(Debug)]
struct LavaMap {
    height: i32,
    width: i32,
    cells: HashMap<(i32, i32), Cell>,
}

impl LavaMap {
    fn from_input(input: &str) -> LavaMap {
        let height = input.split("\n").count() as i32;
        let width = input.split("\n").collect::<Vec<&str>>()[0]
            .split("")
            .filter(|s| !s.is_empty())
            .count() as i32;

        let cells: HashMap<(i32, i32), Cell> = input
            .split("\n")
            .enumerate()
            .flat_map(|(idx, line)| {
                line.split("")
                    .filter(|s| !s.is_empty())
                    .enumerate()
                    .map(move |(idy, digit)| Cell {
                        x: idx.try_into().expect("Error converting usize to i32"),
                        y: idy.try_into().expect("Error converting usize to i32"),
                        value: digit.parse::<u32>().expect("Could not parse value!"),
                    })
            })
            .fold(HashMap::new(), |mut acc, cell| {
                let _ = *acc.entry((cell.x, cell.y)).or_insert(cell);
                acc
            });

        LavaMap {
            height,
            width,
            cells,
        }
    }

    /// get the low points of all cells in the lava map
    fn get_low_points(&self) -> Vec<&Cell> {
        self.cells
            .values()
            .filter_map(|cell| match self.is_low_point(cell) {
                true => Some(cell),
                false => None,
            })
            .collect()
    }

    /// starting from a low point, get all neighbors until we hit a 9
    fn build_basin(&self, starting_point: &Cell) -> HashSet<Cell> {
        let mut basin: HashSet<Cell> = HashSet::new();
        let mut queue = VecDeque::new();

        if starting_point.value < 9 {
            queue.push_back(starting_point);
        }

        while !queue.is_empty() {
            let current_cell = queue
                .pop_front()
                .expect("Somehow found a cell in an empty queue");

            if current_cell.value == 9 {
                continue;
            } else {
                basin.insert(current_cell.clone());
                let neighbors = self.get_neighbors(current_cell);
                for neighbor in neighbors {
                    if !basin.contains(neighbor) {
                        queue.push_back(neighbor)
                    }
                }
            }
        }

        basin
    }

    fn get_neighbors(&self, cell: &Cell) -> Vec<&Cell> {
        let mut neighbors: Vec<Option<&Cell>> = vec![];

        neighbors.push(self.cells.get(&(cell.x + 1, cell.y)));
        neighbors.push(self.cells.get(&(cell.x - 1, cell.y)));
        neighbors.push(self.cells.get(&(cell.x, cell.y - 1)));
        neighbors.push(self.cells.get(&(cell.x, cell.y + 1)));

        neighbors.into_iter().filter_map(identity).collect()
    }

    fn is_low_point(&self, cell: &Cell) -> bool {
        let neighbors = self.get_neighbors(cell);

        let min = neighbors
            .iter()
            .map(|c| c.value)
            .min()
            .expect("Could not find minimum neighbor value!");

        cell.value < min
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
struct Cell {
    x: i32,
    y: i32,
    value: u32,
}

impl Cell {
    fn risk_level(&self) -> u32 {
        1 + self.value
    }
}
