use std::{cmp::max, cmp::min, collections::HashMap};

pub fn vents(skip: bool) {
    if !skip {
        let segments: Vec<Box<dyn Fillable>> = include_str!("inputs/day-5.txt")
            .split("\n")
            .map(|line| {
                // sample line: 424,924 -> 206,706
                let points: Vec<Point> = line
                    .split(" -> ")
                    .map(|point_str| Point::from_str(point_str))
                    .collect();
                make_line_segment(points[0], points[1])
            })
            .collect();

        let straight_only_occurances = segments
            .iter()
            .filter(|f| f.straight())
            .flat_map(|s| s.fill())
            .fold(HashMap::new(), |mut acc, item| {
                *acc.entry(item).or_insert(0) += 1;
                acc
            })
            .into_iter()
            .filter(|(_, num)| num >= &2)
            .count();

        println!(
            "Count of overlapping points (straight lines only): {}",
            straight_only_occurances
        );

        let all_point_occurances = segments
            .iter()
            .flat_map(|s| s.fill())
            .fold(HashMap::new(), |mut acc, item| {
                *acc.entry(item).or_insert(0) += 1;
                acc
            })
            .into_iter()
            .filter(|(_, num)| num >= &2)
            .count();

        println!(
            "Count of overlapping points (with diagonals): {}",
            all_point_occurances
        );
    }
}

#[derive(Clone, Copy, Eq, Hash)]
struct Point {
    x: i32,
    y: i32,
}

impl Point {
    /// Takes a comma-separated string input of x,y
    fn from_str(input: &str) -> Point {
        let as_i32: Vec<i32> = input
            .split(",")
            .map(|s| s.parse::<i32>().expect("Could not parse int!"))
            .collect();

        Point {
            x: as_i32[0],
            y: as_i32[1],
        }
    }
}

impl PartialEq for Point {
    fn eq(&self, other: &Self) -> bool {
        self.x == other.x && self.y == other.y
    }
}

trait Fillable {
    fn fill(&self) -> Vec<Point>;
    fn straight(&self) -> bool {
        true
    }
}

struct HorizontalLine {
    start: Point,
    end: Point,
}

impl Fillable for HorizontalLine {
    fn fill(&self) -> Vec<Point> {
        let mut filled: Vec<Point> = vec![];
        for i in min(self.start.x, self.end.x)..=max(self.start.x, self.end.x) {
            filled.push(Point {
                x: i,
                y: self.start.y,
            })
        }
        filled
    }
}

struct VerticalLine {
    start: Point,
    end: Point,
}

impl Fillable for VerticalLine {
    fn fill(&self) -> Vec<Point> {
        let mut filled: Vec<Point> = vec![];
        for i in min(self.start.y, self.end.y)..=max(self.start.y, self.end.y) {
            filled.push(Point {
                x: self.start.x,
                y: i,
            })
        }
        filled
    }
}

struct DiagonalLine {
    start: Point,
    end: Point,
}

impl Fillable for DiagonalLine {
    fn fill(&self) -> Vec<Point> {
        let x_direction = if self.end.x > self.start.x { 1 } else { -1 };
        let y_direction = if self.end.y > self.start.y { 1 } else { -1 };

        let mut filled: Vec<Point> = vec![];

        for i in 0..=(self.end.x - self.start.x).abs() {
            filled.push(Point {
                x: self.start.x + (i * x_direction),
                y: self.start.y + (i * y_direction),
            });
        }

        filled
    }

    fn straight(&self) -> bool {
        false
    }
}

fn make_line_segment(start: Point, end: Point) -> Box<dyn Fillable> {
    let rise = end.y - start.y;
    let run = end.x - start.x;

    let slope = if run == 0 { i32::MAX } else { rise / run };

    if slope == 0 {
        Box::new(HorizontalLine { start, end })
    } else if slope == i32::MAX {
        Box::new(VerticalLine { start, end })
    } else {
        Box::new(DiagonalLine { start, end })
    }
}
