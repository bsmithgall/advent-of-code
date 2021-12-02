pub fn steer(skip: bool) {
    if !skip {
        let input: Vec<&str> = include_str!("inputs/day-2.txt").split("\n").collect();

        let no_aim = calculate_position_no_aim(&input);
        println!(
            "Final position _without_ aim: horizontal {}, depth {}, times {}",
            no_aim.horiz,
            no_aim.depth,
            no_aim.times()
        );

        let with_aim = calculate_position_with_aim(&input);

        println!(
            "Final position _with_ aim: horizontal {}, depth {}, aim {}, times {}",
            with_aim.horiz,
            with_aim.depth,
            with_aim.aim,
            with_aim.times()
        );
    }
}

trait Position {
    fn times(&self) -> i32;
    fn move_horiz(&mut self, distance: i32);
    fn move_vertical(&mut self, distance: i32);
}

struct PositionNoAim {
    horiz: i32,
    depth: i32,
}

impl Position for PositionNoAim {
    fn times(&self) -> i32 {
        self.horiz * self.depth
    }

    fn move_horiz(&mut self, distance: i32) {
        self.horiz += distance
    }

    fn move_vertical(&mut self, distance: i32) {
        self.depth += distance
    }
}

struct PositionWithAim {
    horiz: i32,
    depth: i32,
    aim: i32,
}

impl Position for PositionWithAim {
    fn times(&self) -> i32 {
        self.horiz * self.depth
    }

    /// forward X does two things:
    /// It increases your horizontal position by X units.
    /// It increases your depth by your aim multiplied by X.
    fn move_horiz(&mut self, distance: i32) {
        self.horiz += distance;
        self.depth += distance * self.aim;
    }

    /// down X increases your aim by X units.
    /// up X decreases your aim by X units.
    fn move_vertical(&mut self, distance: i32) {
        self.aim += distance
    }
}

fn calculate_position_no_aim(input: &Vec<&str>) -> PositionNoAim {
    let position = PositionNoAim { horiz: 0, depth: 0 };
    calculate_position(position, input)
}

fn calculate_position_with_aim(input: &Vec<&str>) -> PositionWithAim {
    let position = PositionWithAim {
        horiz: 0,
        depth: 0,
        aim: 0,
    };
    calculate_position(position, input)
}

fn calculate_position<T: Position>(mut position: T, input: &Vec<&str>) -> T {
    input.iter().for_each(|str| {
        let parts: Vec<&str> = str.split(" ").collect();
        let instruction = parts.get(0).expect("Oh no!");
        let distance = parts.get(1).expect("Oh no!").parse::<i32>().unwrap();

        match &instruction as &str {
            "forward" => position.move_horiz(distance),
            "down" => position.move_vertical(distance),
            "up" => position.move_vertical(distance * -1),
            _ => println!("Got an unexpected instruction {}!", instruction),
        }
    });

    position
}
