use std::collections::HashSet;
use std::io::{self, Write};

pub fn origami(skip: bool) {
    if !skip {
        let instruction_parts: Vec<&str> =
            include_str!("inputs/day-13.txt").split("\n\n").collect();

        let mut sheet = Sheet::from_input(instruction_parts[0]);

        let instructions: Vec<FoldInstruction> = instruction_parts[1]
            .split("\n")
            .map(FoldInstruction::from_input)
            .collect();

        for instruction in instructions {
            sheet = sheet.fold(instruction);
        }

        sheet.print();
    }
}

#[derive(Debug)]
struct Sheet {
    height: i32,
    width: i32,
    points: HashSet<(i32, i32)>,
}

impl Sheet {
    /// this assumes that we just have the coordinate set, not the instructions
    fn from_input(input: &str) -> Sheet {
        let mut width = 0;
        let mut height = 0;
        let points = input
            .split("\n")
            .map(|line| {
                let mut parts = line.split(",");
                let x = parts
                    .next()
                    .expect("Could not find an x value")
                    .parse::<i32>()
                    .expect("Could not parse x value");
                if x > width {
                    width = x
                }

                let y = parts
                    .next()
                    .expect("Could not find an y value")
                    .parse::<i32>()
                    .expect("Could not parse y value");
                if y > height {
                    height = y
                }

                (x, y * -1)
            })
            .collect();
        Sheet {
            points,
            width,
            height,
        }
    }

    fn fold(&self, instruction: FoldInstruction) -> Sheet {
        match instruction {
            FoldInstruction::Left(i) => self.fold_left(i),
            FoldInstruction::Up(i) => self.fold_up(i),
        }
    }

    fn fold_left(&self, at_x: i32) -> Sheet {
        assert!(at_x >= 0, "at_y must be above zero");

        let points = self
            .points
            .iter()
            .map(|(x, y)| {
                let y = y.clone();
                let x: i32 = if x < &at_x {
                    x.clone()
                } else {
                    x.reflect(at_x)
                };

                (x, y)
            })
            .collect();

        Sheet {
            points,
            width: at_x,
            height: self.height,
        }
    }

    // If y is above the fold point, just copy it. Otherwise reflect it across a horizontal line.
    fn fold_up(&self, at_y: i32) -> Sheet {
        assert!(at_y <= 0, "at_y must be below zero");

        let points = self
            .points
            .iter()
            .map(|(x, y)| {
                let x = x.clone();
                let y = if y > &at_y {
                    y.clone()
                } else {
                    y.reflect(at_y)
                };
                (x, y)
            })
            .collect();

        Sheet {
            points,
            height: at_y * -1,
            width: self.width,
        }
    }

    fn print(&self) {
        for x in 0..self.width {
            println!("");
            for y in 0..self.height {
                if self.points.contains(&(x, y * -1)) {
                    print!("# ");
                    io::stdout().flush().unwrap();
                } else {
                    print!(". ");
                    io::stdout().flush().unwrap();
                }
            }
        }
        println!("");
    }
}

#[derive(Clone, Copy)]
enum FoldInstruction {
    Left(i32),
    Up(i32),
}

impl FoldInstruction {
    /// sample input: fold along x=655
    /// will return FoldInstruction::Left(655)
    fn from_input(input: &str) -> FoldInstruction {
        let parts: Vec<&str> = input
            .strip_prefix("fold along ")
            .expect("Could not find prefix!")
            .split("=")
            .collect();
        let value = parts[1]
            .parse::<i32>()
            .expect("Could not parse fold level!");

        match parts[0] {
            "x" => FoldInstruction::Left(value),
            "y" => FoldInstruction::Up(value * -1),
            _ => unreachable!(),
        }
    }
}

trait Reflectable<T> {
    fn reflect(&self, over: T) -> T;
}

impl Reflectable<i32> for i32 {
    fn reflect(&self, over: i32) -> i32 {
        self - ((self - over) * 2)
    }
}

// print result from output:
// . # # # # .
// # . . . . #
// # . . . . #
// . # . . # .
// . . . . . .
// # # # # # #
// # . # . . #
// # . # . . #
// # . . . . #
// . . . . . .
// . . . . # .
// . . . . . #
// # . . . . #
// # # # # # .
// . . . . . .
// # # # # # #
// . . # . . .
// . # . # # .
// # . . . . #
// . . . . . .
// # # # # # #
// . . . . . #
// . . . . . #
// . . . . . #
// . . . . . .
// # # # # # .
// . . . . . #
// . . . . . #
// # # # # # .
// . . . . . .
// . # # # # .
// # . . . . #
// # . . # . #
// . # . # # #
// . . . . . .
// . . . . # .
// . . . . . #
// # . . . . #
// # # # # # .
// . . . . . .