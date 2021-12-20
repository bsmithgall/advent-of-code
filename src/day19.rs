use std::collections::HashMap;
use std::collections::HashSet;
use std::time::Instant;

pub fn beacons_n_scanners(skip: bool) {
    if !skip {
        let mut scanners: Vec<Scanner> = vec![];

        let input = include_str!("inputs/day-19.txt");

        for (idx, line) in input.split("\n\n").enumerate() {
            scanners.push(Scanner::from_input(line, idx));
        }

        let mut matched_scanner_map: HashMap<usize, MatchedScanner> = HashMap::new();
        // set the first scanner from our list as matched
        matched_scanner_map.insert(
            0,
            MatchedScanner {
                idx: 0,
                beacons: scanners[0].beacons.clone(),
                location: (0, 0, 0),
                orientation: 0,
            },
        );

        let instant = Instant::now();
        matched_scanner_map = find_all_matches(scanners, matched_scanner_map);

        let matched_scanners: Vec<&MatchedScanner> = matched_scanner_map.values().collect();
        println!(
            "Total number of beacons: {}",
            count_beacons(&matched_scanners)
        );
        println!(
            "Max manhattan distance between scanners: {}",
            max_manhattan_distance(&matched_scanners)
        );
        println!("Took: {}ms", instant.elapsed().as_millis());
    }
}

trait FlipNSpin<T> {
    fn rotate(&self, rotation: u8) -> T;
    fn orient(&self, orientation: u8) -> T;
    fn transform(&self, rotation: u8, orientation: u8) -> T;
    fn add(&self, other: &T) -> T;
    fn subtract(&self, other: &T) -> T;
    fn manhattan(&self, other: &T) -> i32;
}

type Beacon = (i32, i32, i32);

fn beacon_from_line(line: &str) -> Beacon {
    let coords: Vec<i32> = line
        .split(",")
        .map(|d| d.trim().parse::<i32>().unwrap())
        .collect();

    (coords[0], coords[1], coords[2])
}

fn shift_beacons(beacons: &HashSet<Beacon>, amount: (i32, i32, i32)) -> HashSet<Beacon> {
    beacons.iter().map(|b| b.add(&amount)).collect()
}

impl FlipNSpin<Beacon> for Beacon {
    fn rotate(&self, rotation: u8) -> Beacon {
        match rotation {
            0 => (self.0, self.1, self.2),
            1 => (self.2, self.1, -self.0),
            2 => (-self.0, self.1, -self.2),
            3 => (-self.2, self.1, self.0),
            _ => unreachable!(),
        }
    }

    fn orient(&self, orientation: u8) -> Beacon {
        match orientation {
            0 => (self.0, self.1, self.2),
            1 => (self.0, -self.1, -self.2),
            2 => (self.1, self.0, -self.2),
            3 => (self.1, -self.0, self.2),
            4 => (self.1, self.2, self.0),
            5 => (self.1, -self.2, -self.0),
            _ => unreachable!(),
        }
    }

    fn transform(&self, rotation: u8, orientation: u8) -> Beacon {
        self.orient(orientation).rotate(rotation)
    }

    fn add(&self, other: &Beacon) -> Beacon {
        (self.0 + other.0, self.1 + other.1, self.2 + other.2)
    }

    fn subtract(&self, other: &Beacon) -> Beacon {
        (self.0 - other.0, self.1 - other.1, self.2 - other.2)
    }

    fn manhattan(&self, other: &Beacon) -> i32 {
        (self.0 - other.0).abs() + (self.1 - other.1).abs() + (self.2 - other.2).abs()
    }
}

struct Scanner {
    idx: usize,
    beacons: HashSet<Beacon>,
}

impl Scanner {
    fn from_input(input: &str, idx: usize) -> Scanner {
        let beacons = input
            .lines()
            .enumerate()
            .filter_map(|(idx, line)| {
                if idx == 0 {
                    None
                } else {
                    Some(beacon_from_line(line))
                }
            })
            .collect();
        Scanner { beacons, idx }
    }

    fn orient_beacons(&self, orientation: u8) -> HashSet<Beacon> {
        let _rotation = orientation / 6;
        let _orientation = orientation % 6;

        self.beacons
            .iter()
            .map(|b| b.transform(_rotation, _orientation))
            .collect()
    }

    /// To check if any scanner can "see" any other scanner, we take every beacon in the "other" scanner and find the
    /// difference between that and every beacon in our current scanner. We take that difference to be a candidate position
    /// of the other beacon and then use that difference to see if we have at least twelve matches. If that is the case,
    /// then we know that the beacons can see each other.
    fn check_match(&self, other: &Scanner) -> Option<MatchedScanner> {
        // 6 possible orientations * 4 possible rotations
        for orientation in 0..24 {
            let reoriented = other.orient_beacons(orientation);
            for beacon in &self.beacons {
                for other_beacon in &reoriented {
                    let difference = beacon.subtract(other_beacon);
                    let shifted = shift_beacons(&reoriented, difference);

                    let size = self.beacons.intersection(&shifted).count();

                    if size >= 12 {
                        return Some(MatchedScanner {
                            idx: other.idx,
                            beacons: shifted,
                            location: difference,
                            orientation,
                        });
                    }
                }
            }
        }
        None
    }
}

#[derive(Clone)]
struct MatchedScanner {
    idx: usize,
    beacons: HashSet<Beacon>,
    location: (i32, i32, i32),
    orientation: u8,
}

impl MatchedScanner {
    fn to_scanner(&self) -> Scanner {
        Scanner {
            beacons: self.beacons.clone(),
            idx: self.idx,
        }
    }
}

fn find_scanner_matches(
    to_match: &Scanner,
    all_scanners: &Vec<Scanner>,
    matched: &HashMap<usize, MatchedScanner>,
) -> HashMap<usize, MatchedScanner> {
    let mut new_matches = HashMap::new();
    for i in 1..all_scanners.len() {
        if matched.contains_key(&i) {
            continue;
        }
        if let Some(new_match) = to_match.check_match(&all_scanners[i]) {
            new_matches.insert(new_match.idx, new_match);
        } else {
            continue;
        }
    }

    new_matches
}

fn find_all_matches(
    all_scanners: Vec<Scanner>,
    matches: HashMap<usize, MatchedScanner>,
) -> HashMap<usize, MatchedScanner> {
    let mut currently_matched = HashSet::new();
    let mut new_matches = matches.clone();
    while new_matches.len() < all_scanners.len() {
        let mut current_scanner: Option<Scanner> = None;
        for m in new_matches.values() {
            if !currently_matched.contains(&m.idx) {
                println!("Starting for {}", m.to_scanner().idx);
                current_scanner = Some(m.to_scanner());
                break;
            }
        }
        let scanner = current_scanner.unwrap();
        currently_matched.insert(scanner.idx);
        println!("Searching for matches...");
        let to_extend = find_scanner_matches(&scanner, &all_scanners, &new_matches);
        println!("Found {} matches for {}", to_extend.len(), scanner.idx);
        new_matches.extend(to_extend);
    }
    new_matches
}

fn count_beacons(matched_scanners: &Vec<&MatchedScanner>) -> usize {
    matched_scanners
        .iter()
        .flat_map(|m| m.beacons.clone())
        .collect::<HashSet<Beacon>>()
        .len()
}

fn max_manhattan_distance(matched_scanners: &Vec<&MatchedScanner>) -> i32 {
    let mut max_distance = 0;
    for scanner_one in matched_scanners {
        for scanner_two in matched_scanners {
            let manhattan = scanner_one.location.manhattan(&scanner_two.location);
            if manhattan > max_distance {
                max_distance = manhattan
            }
        }
    }

    max_distance
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_check_match() {
        let scanner_zero = Scanner::from_input(
            "--- scanner 0 ---
404,-588,-901
528,-643,409
-838,591,734
390,-675,-793
-537,-823,-458
-485,-357,347
-345,-311,381
-661,-816,-575
-876,649,763
-618,-824,-621
553,345,-567
474,580,667
-447,-329,318
-584,868,-557
544,-627,-890
564,392,-477
455,729,728
-892,524,684
-689,845,-530
423,-701,434
7,-33,-71
630,319,-379
443,580,662
-789,900,-551
459,-707,401",
            0,
        );

        let scanner_one = Scanner::from_input(
            "--- scanner 1 ---
686,422,578
605,423,415
515,917,-361
-336,658,858
95,138,22
-476,619,847
-340,-569,-846
567,-361,727
-460,603,-452
669,-402,600
729,430,532
-500,-761,534
-322,571,750
-466,-666,-811
-429,-592,574
-355,545,-477
703,-491,-529
-328,-685,520
413,935,-424
-391,539,-444
586,-435,557
-364,-763,-893
807,-499,-711
755,-354,-619
553,889,-390",
            1,
        );

        assert!(scanner_zero.check_match(&scanner_one).is_some());
    }

    #[test]
    fn test_manhattan_distance() {
        let beacon_one = (1105, -1205, 1229);
        let beacon_two = (-92, -2380, -20);

        assert_eq!(beacon_one.manhattan(&beacon_two), 3621);
    }
}
