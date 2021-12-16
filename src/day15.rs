use std::collections::BinaryHeap;
use std::collections::HashSet;

pub fn chitons(skip: bool) {
    if !skip {
        // represent the matrix input as vector, where each element is a node represented as
        // a vector of its outgoing edges.
        let input = include_str!("inputs/day-15.txt");
        let graph = input
            .lines()
            .map(|line| {
                line.chars()
                    .map(|c| c.to_digit(10).unwrap() as usize)
                    .collect()
            })
            .collect();

        let shortest = shortest_path(&graph);
        println!("Shortest path: {}", shortest.unwrap());

        let expanded = expand_grid(&graph, 5);
        println!(
            "Shortest path through expanded grid: {}",
            shortest_path(&expanded).unwrap()
        );
    }
}

#[derive(PartialEq, Eq, Hash, Clone, Copy, Debug)]
struct Position {
    x: isize,
    y: isize,
    value: usize,
}

#[derive(Copy, Clone, Eq, PartialEq)]
struct State {
    cost: usize,
    position: (usize, usize),
}

impl Ord for State {
    // reverse the sort ordering
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        other.cost.cmp(&self.cost)
    }
}

impl PartialOrd for State {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        Some(self.cmp(other))
    }
}

fn shortest_path(graph: &Vec<Vec<usize>>) -> Option<usize> {
    let height = graph.len();
    let width = graph[0].len();

    let mut heap = BinaryHeap::new();
    let mut visited: HashSet<(usize, usize)> = HashSet::new();

    heap.push(State { cost: 0, position: (0, 0), });

    while let Some(State { cost, position }) = heap.pop() {
        let (x, y) = position;
        if visited.contains(&position) {
            continue;
        }

        visited.insert(position);

        if position == (width - 1, height - 1) {
            return Some(cost);
        }

        let neighbors = get_neighbors(x, y, height, width);
        for (neighbor_x, neighbor_y) in neighbors {
            heap.push(State {
                cost: cost + graph[neighbor_x][neighbor_y],
                position: (neighbor_x, neighbor_y),
            })
        }
    }

    None
}

fn get_neighbors(x: usize, y: usize, height: usize, width: usize) -> Vec<(usize, usize)> {
    let mut neighbors = vec![];
    if x > 0 {
        neighbors.push(((x - 1), y));
    }
    if y > 0 {
        neighbors.push((x, (y - 1)));
    }
    if x < height - 1 {
        neighbors.push(((x + 1), y));
    }
    if y < width - 1 {
        neighbors.push((x, (y + 1)));
    }
    neighbors
}

fn expand_grid(grid: &Vec<Vec<usize>>, factor: usize) -> Vec<Vec<usize>> {
    let height = grid.len() * factor;
    let width = grid[0].len() * factor;

    let mut expanded_grid: Vec<Vec<usize>> = (0..height)
        .map(|_| (0..width).map(|_| usize::MAX).collect::<Vec<usize>>())
        .collect();

    for idx in 0..height {
        for idy in 0..width {
            let base_value = (grid[idx % grid.len()][idy % grid[0].len()]
                + (idx / grid.len())
                + (idy / grid[0].len()))
                % 9;
            expanded_grid[idx][idy] = if base_value == 0 { 9 } else { base_value }
        }
    }

    expanded_grid
}
