use std::collections::HashMap;

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
}

#[derive(Clone)]
struct CavePath {
    path: Vec<Cave>,
    visit_counts: HashMap<String, i32>,
    max_small_visits: i32,
}

impl CavePath {
    fn new() -> CavePath {
        let mut visit_counts = HashMap::new();
        visit_counts.insert(String::from("start"), 1);
        CavePath {
            path: vec![Cave::from_name("start")],
            max_small_visits: 0,
            visit_counts,
        }
    }

    fn last_visited(&self) -> &Cave {
        self.path.last().expect("Could not find last cave!")
    }

    fn can_visit(&self, cave: &Cave) -> bool {
        match cave.cave_type {
            CaveType::Big => true,
            CaveType::Terminus => false,
            CaveType::Small => {
                self.max_small_visits < 2
                    || self.visit_counts.get(&cave.name.clone()).unwrap_or(&0) < &1
            } // for part 1, we can just remove the max_small_visits line
        }
    }

    /// visiting creates a new path from an existing path with the new cave
    /// tacked onto the end and the relevant metadata values updated
    fn visit(&self, cave: &Cave) -> CavePath {
        let mut new_path = self.path.clone();
        new_path.push(cave.clone());

        let mut new_visit_counts = self.visit_counts.clone();
        *new_visit_counts.entry(cave.name.clone()).or_insert(0) += 1;

        let current_visit_count = new_visit_counts.get(&cave.name).expect("Oh no");

        let mut new_max_small_visits = self.max_small_visits;
        if cave.cave_type == CaveType::Small && current_visit_count > &new_max_small_visits {
            new_max_small_visits = *current_visit_count
        }

        CavePath {
            path: new_path,
            visit_counts: new_visit_counts,
            max_small_visits: new_max_small_visits,
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
        let mut total_paths = 0;

        let mut queue: Vec<CavePath> = vec![CavePath::new()];

        while !queue.is_empty() {
            let current_path = queue.pop().expect("Could not find cave path!");
            let current_cave = current_path.last_visited();

            let neighbors = self
                .map
                .get(current_cave)
                .expect("Could not find neighbors on map!");

            for n in neighbors {
                if n.name == "end" {
                    total_paths += 1
                } else if current_path.can_visit(n) {
                    let new_path = current_path.visit(n);
                    queue.push(new_path)
                }
            }
        }

        total_paths
    }
}
