type Coord = (i64, i64);

pub fn reactor(skip: bool) {
    if !skip {
        let mut reactor = Reactor::from_input(include_str!("inputs/day-22.txt"));
        for (idx, i) in reactor.instructions.iter().enumerate() {
            reactor.activated = reactor.activate(*i);
            if idx == 19 {
                println!("Total activated within initialization step: {}", reactor.activated_count());
            }
        }

        println!("Total activated: {}", reactor.activated_count());
    }
}

struct Reactor {
    activated: Vec<Cube>,
    instructions: Vec<Instruction>,
}

impl Reactor {
    fn from_input(input: &str) -> Reactor {
        let instructions = input.lines().map(Instruction::from_input).collect();

        Reactor {
            activated: Vec::new(),
            instructions,
        }
    }

    fn activate(&self, instruction: Instruction) -> Vec<Cube> {
        let mut activated_from_instructions = Vec::new();
        for cube in &self.activated {
            activated_from_instructions.append(&mut cube.remove(&instruction.cube))
        }

        if instruction.on {
            activated_from_instructions.push(instruction.cube);
        }

        activated_from_instructions
    }

    fn activated_count(&self) -> i64 {
        self.activated.iter().map(Cube::volume).sum::<i64>()
    }
}

#[derive(PartialEq, Eq, Debug, Clone, Copy)]
struct Instruction {
    on: bool,
    cube: Cube,
}

impl Instruction {
    fn from_input(input: &str) -> Instruction {
        let parts: Vec<&str> = input.split(" ").collect();
        let on = parts[0] == "on";

        let cube = Cube::from_input(parts[1]);

        Instruction { on, cube }
    }
}

#[derive(PartialEq, Eq, Debug, Clone, Copy)]
struct Cube {
    x: Coord,
    y: Coord,
    z: Coord,
}

impl Cube {
    /// sample input: "on x=-40..7,y=-3..49,z=-48..6"
    fn from_input(input: &str) -> Cube {
        let coords: Vec<(i64, i64)> = input
            .split(",")
            .map(|coord| {
                let parts: Vec<&str> = coord[2..].split("..").collect();
                (
                    parts[0].parse::<i64>().unwrap(),
                    // cube ranges are inclusive
                    parts[1].parse::<i64>().unwrap() + 1,
                )
            })
            .collect();

        Cube {
            x: coords[0],
            y: coords[1],
            z: coords[2],
        }
    }

    /// Calculates the volume of the given cube. Note that the cubes are inclusive on
    /// both sides, so we add one to handle this.
    fn volume(&self) -> i64 {
        (self.x.1 - self.x.0) * (self.y.1 - self.y.0) * (self.z.1 - self.z.0)
    }

    /// Sometimes when we build cubes we end up with ending points that come before starting
    /// points along the respective axes
    fn valid(&self) -> bool {
        self.x.1 > self.x.0 && self.y.1 > self.y.0 && self.z.1 > self.z.0
    }

    /// Given another cube, validate that this cube and that other cube have some intersection based
    /// on their axes
    fn intersects(&self, other: &Cube) -> bool {
        self.x.0 < other.x.1
            && self.y.0 < other.y.1
            && self.z.0 < other.z.1
            && self.x.1 > other.x.0
            && self.y.1 > other.y.0
            && self.z.1 > other.z.0
    }

    /// Given another cube, remove all parts of overlap from this cube
    fn remove(&self, other: &Cube) -> Vec<Cube> {
        // no intersection, just return ourselves
        if !self.intersects(other) {
            return vec![*self];
        }

        let mut splits = vec![];

        for x in 0..=2 {
            for y in 0..=2 {
                for z in 0..=2 {
                    if x != 1 || y != 1 || z != 1 {
                        splits.push(Cube {
                            x: Cube::split_along(self.x, other.x, x),
                            y: Cube::split_along(self.y, other.y, y),
                            z: Cube::split_along(self.z, other.z, z),
                        })
                    }
                }
            }
        }

        splits.into_iter().filter(Cube::valid).collect()
    }

    fn split_along(_self: Coord, other: Coord, factor: u8) -> Coord {
        match factor {
            0 => (_self.0, _self.0.max(other.0)),
            1 => (_self.0.max(other.0), _self.1.min(other.1)),
            2 => (_self.1.min(other.1), _self.1),
            _ => unreachable!(),
        }
    }
}

#[cfg(test)]
mod test {
    use super::*;

    fn count_cubes(mut r: Reactor) -> i64 {
        for i in r.instructions.iter() {
            r.activated = r.activate(*i);
        }

        r.activated_count()
    }

    #[test]
    fn test_cube_split_one(){
        let r = Reactor::from_input("on x=10..12,y=10..12,z=10..12");
        assert_eq!(count_cubes(r), 27);
    }

    #[test]
    fn test_cube_split_two(){
        let r = Reactor::from_input("on x=10..12,y=10..12,z=10..12
on x=11..13,y=11..13,z=11..13");

        assert_eq!(count_cubes(r), 46);
    }

    #[test]
    fn test_cube_split_three() {
        let r = Reactor::from_input("on x=10..12,y=10..12,z=10..12
on x=11..13,y=11..13,z=11..13
off x=9..11,y=9..11,z=9..11");

assert_eq!(count_cubes(r), 38);
    }

    #[test]
    fn test_cube_split_four() {
        let r = Reactor::from_input("on x=10..12,y=10..12,z=10..12
on x=11..13,y=11..13,z=11..13
off x=9..11,y=9..11,z=9..11
on x=10..10,y=10..10,z=10..10");

assert_eq!(count_cubes(r), 39);
    }
}
