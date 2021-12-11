pub fn octopus(skip: bool) {
    if !skip {
        let mut octopus_matrix: Vec<Vec<u8>> = include_str!("inputs/day-11.txt")
            .split("\n")
            .map(|line| {
                line.chars()
                    .map(|x| x.to_digit(10).unwrap() as u8)
                    .collect()
            })
            .collect();

        // part 1 commented out because we have one mutating octopus matrix
        // let mut flashes = 0;
        // let mut i = 0;

        // while i < 100 {
        //     let new_count = tick(&mut octopus_matrix);
        //     flashes += new_count;
        //     i += 1
        // }

        let mut first_flash_day = 1;
        while tick(&mut octopus_matrix) < 100 {
            first_flash_day += 1
        }

        println!("First tick of simultaneous flashing: {}", first_flash_day)
    }
}

#[derive(Debug)]
struct Octopus {
    x: usize,
    y: usize,
}

fn tick(matrix: &mut Vec<Vec<u8>>) -> u16 {
    let mut flash_count = 0;

    for x in 0..10 {
        for y in 0..10 {
            matrix[y][x] += 1;
            if matrix[y][x] == 10 {
                flash_count += flash(matrix, Octopus { x, y })
            }
        }
    }

    for row in matrix {
        for col in row {
            if *col > 9 {
                *col = 0
            }
        }
    }

    flash_count
}

fn flash(matrix: &mut Vec<Vec<u8>>, o: Octopus) -> u16 {
    let mut flash_count = 1;

    for neighbor in get_neighbors(o) {
        matrix[neighbor.y][neighbor.x] += 1;
        if matrix[neighbor.y][neighbor.x] == 10 {
            flash_count += flash(matrix, neighbor)
        }
    }

    flash_count
}

fn get_neighbors(o: Octopus) -> Vec<Octopus> {
    let mut neighbors = vec![];
    let x = o.x;
    let y = o.y;
    if x > 0 {
        neighbors.push(Octopus { x: x - 1, y });
        if y > 0 {
            neighbors.push(Octopus { x: x - 1, y: y - 1 });
        }
        if y < 9 {
            neighbors.push(Octopus { x: x - 1, y: y + 1 });
        }
    }
    if x < 9 {
        neighbors.push(Octopus { x: x + 1, y });
        if y > 0 {
            neighbors.push(Octopus { x: x + 1, y: y - 1 });
        }
        if y < 9 {
            neighbors.push(Octopus { x: x + 1, y: y + 1 });
        }
    }
    if y > 0 {
        neighbors.push(Octopus { x, y: y - 1 });
    }
    if y < 9 {
        neighbors.push(Octopus { x, y: y + 1 });
    }
    neighbors
}
