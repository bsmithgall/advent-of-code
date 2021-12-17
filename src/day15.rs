use std::collections::BinaryHeap;

pub fn chitons(skip: bool) {
    if !skip {
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
        let instant = std::time::Instant::now();
        println!(
            "Shortest path through expanded grid: {}. Took {}ms",
            shortest_path(&expanded).unwrap(),
            instant.elapsed().as_millis()
        );
    }
}

#[derive(PartialEq, Eq, Hash, Clone, Copy, Debug)]
struct Position {
    x: isize,
    y: isize,
    value: usize,
}

#[derive(Copy, Clone, Eq, PartialEq, Debug)]
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
    let mut checked_paths: Vec<Vec<usize>> = (0..graph.len())
        .map(|_| {
            (0..graph[0].len())
                .map(|_| usize::MAX)
                .collect::<Vec<usize>>()
        })
        .collect();

    let height = graph.len();
    let width = graph[0].len();

    let mut heap = BinaryHeap::new();

    heap.push(State {
        cost: 0,
        position: (0, 0),
    });
    checked_paths[0][0] = 0;

    while let Some(State { cost, position }) = heap.pop() {
        let (x, y) = position;

        if position == (width - 1, height - 1) {
            return Some(cost);
        }

        if cost > checked_paths[x][y] {
            continue;
        }

        let neighbors = get_neighbors(x, y, height, width);
        for (neighbor_x, neighbor_y) in neighbors {
            let next = State {
                cost: cost + graph[neighbor_x][neighbor_y],
                position: (neighbor_x, neighbor_y),
            };

            if next.cost < checked_paths[neighbor_x][neighbor_y] {
                heap.push(next);
                checked_paths[neighbor_x][neighbor_y] = next.cost
            }
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
    let original_height = grid.len();
    let original_width = grid[0].len();
    let new_height = original_height * factor;
    let new_width = original_width * factor;

    let mut expanded_grid: Vec<Vec<usize>> = (0..new_height)
        .map(|_| (0..new_width).map(|_| usize::MAX).collect::<Vec<usize>>())
        .collect();

    for idx in 0..new_height {
        for idy in 0..new_width {
            let base_value = (grid[idx % original_height][idy % original_width]
                + (idx / original_height)
                + (idy / original_width))
                % 9;
            expanded_grid[idx][idy] = if base_value == 0 { 9 } else { base_value }
        }
    }

    expanded_grid
}
