use std::collections::HashMap;

pub fn crab_move(skip: bool) {
    if !skip {
        let crab_map: HashMap<i32, i32> = include_str!("inputs/day-7.txt")
            .split(",")
            .map(|s| s.parse::<i32>().expect("Could not parse int!"))
            .into_iter()
            .fold(HashMap::new(), |mut acc, item| {
                *acc.entry(item).or_insert(0) += 1;
                acc
            });

        let crabs = Crabs {
            position_map: crab_map,
        };

        let mut min_fuel_naive = i32::MAX;
        let mut min_fuel_naive_position = i32::MAX;

        let mut min_fuel_crab = i32::MAX;
        let mut min_fuel_crab_position = i32::MAX;

        for pos in crabs.min_position()..=crabs.max_position() {
            let naive_fuel_at_pos = crabs.calculate_fuel_use_naive(pos);
            if naive_fuel_at_pos < min_fuel_naive {
                min_fuel_naive = naive_fuel_at_pos;
                min_fuel_naive_position = pos;
            }

            let crab_fuel_at_pos = crabs.calculate_fuel_use(pos);
            if crab_fuel_at_pos < min_fuel_crab {
                min_fuel_crab = crab_fuel_at_pos;
                min_fuel_crab_position = pos;
            }
        }

        println!(
            "Min fuel used (naive) {}, min fuel position (naive): {}",
            min_fuel_naive, min_fuel_naive_position
        );

        println!(
            "Min fuel used (crab) {}, min fuel position (crab): {}",
            min_fuel_crab, min_fuel_crab_position
        );
    }
}

struct Crabs {
    position_map: HashMap<i32, i32>,
}

impl Crabs {
    /// calculates fuel usage to realign all crabs at the input position pos
    /// this is the naive approach used for part one
    fn calculate_fuel_use_naive(&self, pos: i32) -> i32 {
        self.position_map
            .iter()
            .fold(0, |mut acc, (crab_pos, count)| {
                acc += (crab_pos - pos).abs() * count;
                acc
            })
    }

    /// calculates fuel use to realign all crabs at the input position pos
    /// this uses the additional step approaches for part two (one step = one fuel, two steps = two fuel etc)
    fn calculate_fuel_use(&self, pos: i32) -> i32 {
        self.position_map
            .iter()
            .fold(0, |mut acc, (crab_pos, count)| {
                let position_diff = (crab_pos - pos).abs();
                acc += ((position_diff * (position_diff + 1)) / 2) * count;
                acc
            })
    }

    fn min_position(&self) -> i32 {
        self.position_map.keys().min().unwrap().clone()
    }

    fn max_position(&self) -> i32 {
        self.position_map.keys().max().unwrap().clone()
    }
}
