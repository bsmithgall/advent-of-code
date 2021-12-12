use std::collections::{HashMap};

pub fn navigate(skip: bool) {
    if !skip {
        let graph = CaveGraph::from_input(include_str!("inputs/day-12.txt"));

        println!(
            "Total paths through cave systems: {}",
            graph.calculate_paths()
        );
    }
}

#[derive(PartialEq, Eq, Hash, Clone, Copy, Debug)]
enum CaveType {
    Big,
    Small,
    Terminus,
}

impl CaveType {
    fn from_input(str: &str) -> CaveType {
        if str.to_uppercase() == str {
            CaveType::Big
        } else if str == "start" || str == "end" {
            CaveType::Terminus
        } else {
            CaveType::Small
        }
    }
}

#[derive(PartialEq, Eq, Hash, Clone, Debug)]
struct Cave {
    cave_type: CaveType,
    name: String,
}

impl Cave {
    fn from_name(name: &str) -> Cave {
        Cave {
            cave_type: CaveType::from_input(name),
            name: String::from(name),
        }
    }

    fn can_visit(&self, already_visited: &Vec<&Cave>) -> bool {
        let small_visit_count = already_visited
            .into_iter()
            .filter(|c| c.cave_type == CaveType::Small)
            .fold(HashMap::new(), |mut acc, cave| {
                *acc.entry(cave.name.clone()).or_insert(0) += 1;
                acc
            });

        let max_small_visit = small_visit_count.values().max().unwrap_or(&0);
        let current_visit_count = small_visit_count.get(&self.name).unwrap_or(&0);

        match self.cave_type {
            CaveType::Big => true,
            CaveType::Terminus => false,
            CaveType::Small => max_small_visit < &2 || current_visit_count < &1,
        }
    }
}

#[derive(Debug)]
struct CaveGraph {
    map: HashMap<Cave, Vec<Cave>>,
}

impl CaveGraph {
    fn from_input(input: &str) -> CaveGraph {
        let mut map: HashMap<Cave, Vec<Cave>> = HashMap::new();

        input.split("\n").for_each(|line| {
            let caves: Vec<Cave> = line.split("-").map(Cave::from_name).collect();
            map.entry(caves[0].clone())
                .or_insert(vec![])
                .push(caves[1].clone());
            map.entry(caves[1].clone())
                .or_insert(vec![])
                .push(caves[0].clone());
        });

        CaveGraph { map }
    }

    fn calculate_paths(&self) -> u32 {
        let mut total_paths: u32 = 0;

        let start = Cave::from_name("start");
        let mut queue: Vec<Vec<&Cave>> = vec![vec![&start]];

        while !queue.is_empty() {
            let current_path = queue.pop().expect("Could not find current path!");
            let current_cave = current_path.last().expect("Could not find current cave!");

            let neighbors = self
                .map
                .get(&current_cave)
                .expect("Could not find cave on map!");

            for n in neighbors {
                let mut new_path = current_path.clone();

                if n.name == "end" {
                    total_paths += 1
                } else if n.can_visit(&new_path) {
                    new_path.push(n);
                    queue.push(new_path)
                }
            }
        }

        total_paths
    }
}
