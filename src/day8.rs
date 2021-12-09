use std::collections::{HashMap, HashSet};

pub fn displays(skip: bool) {
    if !skip {
        let segments: Vec<Reading> = include_str!("inputs/day-8.txt")
            .split("\n")
            .map(Reading::from_input)
            .collect();

        let easy_digit_count: usize = segments.iter().map(Reading::easy_digit_count).sum();
        println!("Easy digit count: {}", easy_digit_count);

        let decoded_sum: i32 = segments.iter().map(Reading::decode_output).sum();

        println!("Decoded sum of all inputs: {}", decoded_sum);
    }
}

struct Reading {
    signal_patterns: Vec<String>,
    output_values: Vec<String>,
}

impl Reading {
    fn from_input(line: &str) -> Reading {
        let parts: Vec<&str> = line.split(" | ").collect();

        Reading {
            signal_patterns: parts[0].split(" ").map(String::from).collect(),
            output_values: parts[1].split(" ").map(String::from).collect(),
        }
    }

    /// for part one, we need to calculate the number of "easy" digits that appear
    /// in the output. the "easy" digits are 1, 4, 7, and 8. they are easy to identify
    /// because they have unique numbers of segments that light up:
    ///
    /// - 1: 2 segments
    /// - 4: 4 segments
    /// - 7: 3 segments
    /// - 8: 7 segments
    fn easy_digit_count(&self) -> usize {
        self.output_values
            .iter()
            .filter(|s| match s.len() {
                2 | 3 | 4 | 7 => true,
                _ => false,
            })
            .count()
    }

    fn decode_output(&self) -> i32 {
        let display_map = self.make_display_map();
        let mut total = 0;
        for (idx, value) in self.output_values.iter().rev().enumerate() {
            total += 10_i32.pow(idx.try_into().unwrap()) * display_map.parse_str(value);
        }

        total
    }

    /// Based on the display signals, we should be able to determine which letters go in which positions
    /// 1. Compare seven against one. Whichever letter is in seven but not in one is the top
    /// 2. Compare one against six, nine, and zero. The top right position should be missing from one of those three (six), and then
    ///    the bottom right should be whichever the other letter in one is
    /// 3. Compare two, three, and five against four. Four should have two positions present in all three that are
    ///    currently uknown (middle & bottom). Determining which of those is present in four should
    ///    give us the middle, and the missing one should be the bottom
    /// 4. We should then be able to determine the left side by checking what things we don't have set against four. There are
    ///    two pieces remaining; the one that is a part of four will be the top left, the other the bottom left.
    fn make_display_map(&self) -> DisplayMap {
        let mut display_map = DisplayMap::new();
        // step one above
        display_map.set_top(self.get_one(), self.get_seven());
        // step two above
        display_map.set_right(self.get_one(), self.get_six_segment());
        // step three above
        display_map.set_middle_and_top_left(self.get_four(), self.get_five_segment());
        // step four above
        display_map.set_top_left(self.get_four());
        display_map.set_bottom_left();

        display_map
    }

    /// return the string pattern associated with "1"
    fn get_one(&self) -> String {
        self.signal_patterns
            .iter()
            .find(|s| s.len() == 2)
            .expect("No one reading!")
            .to_string()
    }

    /// return the string pattern associated with "4"
    fn get_four(&self) -> String {
        self.signal_patterns
            .iter()
            .find(|s| s.len() == 4)
            .expect("No four reading!")
            .to_string()
    }

    /// return the string pattern associated with "7"
    fn get_seven(&self) -> String {
        self.signal_patterns
            .iter()
            .find(|s| s.len() == 3)
            .expect("No seven reading!")
            .to_string()
    }

    /// return the string patterns associated with "2", "3", and "5"
    fn get_five_segment(&self) -> Vec<String> {
        self.signal_patterns
            .iter()
            .filter(|s| s.len() == 5)
            .map(String::from)
            .collect()
    }

    /// return the string patterns associated with "6", "9", and "0"
    fn get_six_segment(&self) -> Vec<String> {
        self.signal_patterns
            .iter()
            .filter(|s| s.len() == 6)
            .map(String::from)
            .collect()
    }
}

#[derive(Debug, Eq, PartialEq, Hash)]
enum DisplayPart {
    Top,
    TopRight,
    TopLeft,
    Middle,
    BottomRight,
    BottomLeft,
    Bottom,
}

impl DisplayPart {
    fn two() -> HashSet<&'static DisplayPart> {
        let mut s = HashSet::new();

        s.insert(&DisplayPart::Top);
        s.insert(&DisplayPart::TopRight);
        s.insert(&DisplayPart::Middle);
        s.insert(&DisplayPart::BottomLeft);
        s.insert(&DisplayPart::Bottom);

        s
    }

    fn three() -> HashSet<&'static DisplayPart> {
        let mut s = HashSet::new();

        s.insert(&DisplayPart::Top);
        s.insert(&DisplayPart::TopRight);
        s.insert(&DisplayPart::Middle);
        s.insert(&DisplayPart::BottomRight);
        s.insert(&DisplayPart::Bottom);

        s
    }

    fn five() -> HashSet<&'static DisplayPart> {
        let mut s = HashSet::new();

        s.insert(&DisplayPart::Top);
        s.insert(&DisplayPart::TopLeft);
        s.insert(&DisplayPart::Middle);
        s.insert(&DisplayPart::BottomRight);
        s.insert(&DisplayPart::Bottom);

        s
    }

    fn six() -> HashSet<&'static DisplayPart> {
        let mut s = HashSet::new();

        s.insert(&DisplayPart::Top);
        s.insert(&DisplayPart::TopLeft);
        s.insert(&DisplayPart::Middle);
        s.insert(&DisplayPart::BottomLeft);
        s.insert(&DisplayPart::BottomRight);
        s.insert(&DisplayPart::Bottom);

        s
    }

    fn nine() -> HashSet<&'static DisplayPart> {
        let mut s = HashSet::new();

        s.insert(&DisplayPart::Top);
        s.insert(&DisplayPart::TopLeft);
        s.insert(&DisplayPart::TopRight);
        s.insert(&DisplayPart::Middle);
        s.insert(&DisplayPart::BottomRight);
        s.insert(&DisplayPart::Bottom);

        s
    }

    fn zero() -> HashSet<&'static DisplayPart> {
        let mut s = HashSet::new();

        s.insert(&DisplayPart::Top);
        s.insert(&DisplayPart::TopLeft);
        s.insert(&DisplayPart::TopRight);
        s.insert(&DisplayPart::BottomLeft);
        s.insert(&DisplayPart::BottomRight);
        s.insert(&DisplayPart::Bottom);

        s
    }
}

struct DisplayMap {
    map: HashMap<String, DisplayPart>,
}

impl DisplayMap {
    fn new() -> DisplayMap {
        DisplayMap {
            map: HashMap::new(),
        }
    }

    fn set_top(&mut self, one: String, seven: String) {
        let top = seven.missing_from(one);
        self.set_value(top, DisplayPart::Top);
    }

    fn set_right(&mut self, one: String, six_nine_zero: Vec<String>) {
        let top_right = six_nine_zero
            .into_iter()
            .map(|elem| one.missing_from(elem))
            .find(|x| !x.is_empty())
            .expect("Could not find top right!");

        let bottom_right = one.missing_from(top_right.clone());
        self.set_value(top_right.clone(), DisplayPart::TopRight);
        self.set_value(bottom_right, DisplayPart::BottomRight);
    }

    fn set_middle_and_top_left(&mut self, four: String, two_three_five: Vec<String>) {
        let letter_count: HashMap<&str, i32> = two_three_five
            .iter()
            .flat_map(|s| s.split(""))
            .fold(HashMap::new(), |mut acc, item| {
                *acc.entry(item).or_insert(0) += 1;
                acc
            });

        let bottom_and_middle: String = letter_count
            .into_iter()
            .filter_map(|(key, value)| {
                if value == 3 && !self.map.contains_key(key) {
                    Some(key)
                } else {
                    None
                }
            })
            .collect::<Vec<&str>>()
            .join("");

        let bottom = bottom_and_middle.missing_from(four);
        self.set_value(bottom.clone(), DisplayPart::Bottom);
        let middle = bottom_and_middle.missing_from(bottom);
        self.set_value(middle, DisplayPart::Middle);
    }

    fn set_top_left(&mut self, four: String) {
        let top_left = four.missing_from(self.known_positions());
        self.set_value(top_left, DisplayPart::TopLeft);
    }

    fn set_bottom_left(&mut self) {
        let bottom_right = String::from("abcdefg").missing_from(self.known_positions());
        self.set_value(bottom_right, DisplayPart::BottomLeft);
    }

    /// returns a string of all currently known positions (like "abcd")
    fn known_positions(&self) -> String {
        self.map
            .keys()
            .map(String::from)
            .collect::<Vec<String>>()
            .join("")
    }

    fn set_value(&mut self, key: String, value: DisplayPart) {
        if key.len() != 1 {
            panic!("Could not set value! Key had invalid length");
        }

        self.map.insert(key, value);
    }

    fn parse_str(&self, from_str: &str) -> i32 {
        match from_str.len() {
            2 => 1,
            3 => 7,
            4 => 4,
            7 => 8,
            5 | 6 => self.parse_segment_str(from_str),
            _ => panic!("Invalid display string"),
        }
    }

    fn parse_segment_str(&self, from_str: &str) -> i32 {
        let mut s = HashSet::new();

        for l in from_str.split("") {
            if l.is_empty() {
                continue;
            }
            let display_value = self.map.get(l).expect("Could not find letter!");
            s.insert(display_value);
        }

        if s == DisplayPart::two() {
            2
        } else if s == DisplayPart::three() {
            3
        } else if s == DisplayPart::five() {
            5
        } else if s == DisplayPart::six() {
            6
        } else if s == DisplayPart::nine() {
            9
        } else if s == DisplayPart::zero() {
            0
        } else {
            panic!("Invalid five segment string!")
        }
    }
}

trait Differentiable<S> {
    fn difference(&self, other: S) -> S;
    fn missing_from(&self, other: S) -> S;
}

impl Differentiable<String> for String {
    /// given the string "abc" and the string "bc", returns "a"
    fn difference(&self, other: String) -> String {
        let mut diff = Vec::new();
        let mut v_other: Vec<&str> = other.split("").into_iter().collect();

        for e1 in self.split("").into_iter() {
            if let Some(pos) = v_other.iter().position(|e2| e1 == *e2) {
                v_other.remove(pos);
            } else {
                diff.push(e1);
            }
        }

        diff.append(&mut v_other);

        diff.join("")
    }

    /// get the letters in self that are missing in other
    fn missing_from(&self, other: String) -> String {
        let mut diff = Vec::new();
        let v_other: Vec<&str> = other.split("").into_iter().collect();

        for e1 in self.split("").into_iter() {
            if v_other.iter().position(|e2| e1 == *e2).is_none() {
                diff.push(e1);
            }
        }

        diff.join("")
    }
}
