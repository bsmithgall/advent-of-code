use std::collections::HashMap;

pub fn lanternfish(skip: bool) {
    if !skip {
        let initial_fish: Vec<u32> = include_str!("inputs/day-6.txt")
            .split(",")
            .map(|s| s.parse::<u32>().expect("Could not parse int!"))
            .collect();

        let mut day = 0;

        let mut school = LanternfishSchool::from_input(initial_fish);

        while day < 256 {
            school.tick();
            day += 1;
            if day == 80 { println!("School size after day 80: {}", school.size()) }
        }

        println!("School size after day 256: {}", school.size())
    }
}

#[derive(Debug)]
struct LanternfishSchool {
    fish: HashMap<u32, u64>,
}

impl LanternfishSchool {
    fn from_input(input: Vec<u32>) -> LanternfishSchool {
        LanternfishSchool {
            fish: input.iter().fold(HashMap::new(), |mut acc, item| {
                *acc.entry(item.clone()).or_insert(0) += 1;
                acc
            }),
        }
    }

    /// We need to take our existing hashmap and do the following:
    ///  - For all non-zero numbers, move them down by one
    ///  - For all zeroes, move them to six
    ///  - For all zeroes, add an additional to eight
    fn tick(&mut self) {
        let mut new_fish = HashMap::new();

        for (key, value) in self.fish.iter() {
            if key != &0 {
                new_fish.insert(key - 1, value.clone());
            } else {
                continue
            }
        }

        let zero_value = self.fish.get(&0).or(Some(&0)).expect("Oh no!").clone();
        // do zero last to make sure everything else has been calculated
        new_fish.insert(8, zero_value);
        *new_fish.entry(6).or_insert(0) += zero_value;

        self.fish = new_fish
    }

    fn size(&self) -> u64 {
        self.fish.values().sum()
    }
}
