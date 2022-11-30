use std::collections::HashMap;
use std::fmt::Debug;
use std::time::Instant;

pub fn trench_map(skip: bool) {
    if !skip {
        let mut trench_map = TrenchMap::from_input(include_str!("inputs/day-20.txt"));

        println!(
            "Light pixels after two steps: {}",
            trench_map.enhance().enhance().count_light_pixels()
        );

        let instant = Instant::now();
        let mut step = 0;
        while step < 50 {
            trench_map = trench_map.enhance();
            step += 1
        }

        println!(
            "Light pixels after fifty steps: {}",
            trench_map.count_light_pixels()
        );
        println!("Took {}ms", instant.elapsed().as_millis());
    }
}

#[derive(Clone, Copy, PartialEq, Eq)]
enum Pixel {
    Light,
    Dark,
}

impl Pixel {
    fn from_char(c: char) -> Pixel {
        match c {
            '#' => Pixel::Light,
            '.' => Pixel::Dark,
            _ => {
                println!("Unreachable char: \"{}\"", c);
                unreachable!()
            }
        }
    }

    fn to_bit(&self) -> u8 {
        match self {
            Self::Light => 1,
            Self::Dark => 0,
        }
    }
}

impl Debug for Pixel {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Light => f.write_fmt(format_args!("{}", "#")),
            Self::Dark => f.write_fmt(format_args!("{}", ".")),
        }
    }
}

struct TrenchMap {
    algorithm: Vec<Pixel>,
    map: HashMap<(isize, isize), Pixel>,
    width: isize,
    height: isize,
    edges: Pixel,
}

impl TrenchMap {
    fn from_input(input: &str) -> TrenchMap {
        let parts: Vec<&str> = input.split("\n\n").collect();

        let algorithm = parts[0].chars().map(Pixel::from_char).collect();

        let height = parts[1].split("\n").count() as isize;
        let width = parts[1].split("\n").collect::<Vec<&str>>()[0]
            .chars()
            .count() as isize;

        let map: HashMap<(isize, isize), Pixel> = parts[1]
            .split("\n")
            .enumerate()
            .flat_map(|(idy, line)| {
                line.trim().chars().enumerate().map(move |(idx, c)| {
                    let x = idx.try_into().unwrap();
                    let y = idy.try_into().unwrap();
                    ((x, y), Pixel::from_char(c))
                })
            })
            .collect();

        TrenchMap {
            algorithm,
            map,
            height,
            width,
            edges: Pixel::Dark,
        }
    }

    fn get_enhancement_bits(&self, x: isize, y: isize) -> Vec<u8> {
        let mut bits = vec![];

        bits.push(self.get_pixel(x - 1, y - 1));
        bits.push(self.get_pixel(x, y - 1));
        bits.push(self.get_pixel(x + 1, y - 1));
        bits.push(self.get_pixel(x - 1, y));
        bits.push(self.get_pixel(x, y));
        bits.push(self.get_pixel(x + 1, y));
        bits.push(self.get_pixel(x - 1, y + 1));
        bits.push(self.get_pixel(x, y + 1));
        bits.push(self.get_pixel(x + 1, y + 1));

        bits.iter().map(Pixel::to_bit).collect()
    }

    fn get_pixel(&self, x: isize, y: isize) -> Pixel {
        self.map.get(&(x, y)).unwrap_or(&self.edges).clone()
    }

    fn get_enhancement_pixel(&self, x: isize, y: isize) -> Pixel {
        *self
            .algorithm
            .get(bits_to_u32(&self.get_enhancement_bits(x, y)))
            .expect("Could not find lookup pixel!")
    }

    fn enhance(&self) -> TrenchMap {
        // first, surround the existing map with darkness
        let surrounded = self.surround();

        // then walk through each value in our expanded map and set the new value to whatever we get from
        // calling .get_enhancement_pixel
        let new_map = surrounded
            .map
            .iter()
            .map(|((x, y), _)| ((*x, *y), surrounded.get_enhancement_pixel(*x, *y)))
            .collect();

        TrenchMap {
            map: new_map,
            algorithm: self.algorithm.clone(),
            height: surrounded.height,
            width: surrounded.width,
            edges: self.next_edges(),
        }
    }

    /// The map is surrounded infinitely by dark pixels on all sides. This method fakes that by
    /// taking the existing trench map and adding a square of dark pixels around each of the borders.
    /// All coordinates get pushed up by one, and the overall width/height of the grid grow by
    /// two (one on each of the four sides)
    fn surround(&self) -> TrenchMap {
        let mut new_map: HashMap<(isize, isize), Pixel> = self
            .map
            .iter()
            .map(|((x, y), pixel)| ((*x + 1, *y + 1), *pixel))
            .collect();

        for i in 0..=self.height + 1 {
            new_map.insert((0, i), self.edges);
            new_map.insert((self.height + 1, i), self.edges);
        }

        for i in 0..=self.width + 1 {
            new_map.insert((i, 0), self.edges);
            new_map.insert((i, self.width + 1), self.edges);
        }

        TrenchMap {
            map: new_map,
            algorithm: self.algorithm.clone(),
            height: self.height + 2,
            width: self.width + 2,
            edges: self.edges,
        }
    }

    fn count_light_pixels(&self) -> usize {
        self.map.values().filter(|p| *p == &Pixel::Light).count()
    }

    /// There are two possible cases here. In the first case, we have input
    fn next_edges(&self) -> Pixel {
        if self.algorithm[0] == Pixel::Dark {
            Pixel::Dark
        } else if self.edges == Pixel::Dark {
            Pixel::Light
        } else {
            Pixel::Dark
        }
    }
}

impl Debug for TrenchMap {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        for y in 0..self.height {
            writeln!(f)?;
            for x in 0..self.width {
                write!(
                    f,
                    "{:?}",
                    self.map
                        .get(&(x, y))
                        .expect(format!("Could not find value for {}, {}", x, y).as_str())
                )?
            }
        }
        Ok(())
    }
}

fn bits_to_u32(bits: &[u8]) -> usize {
    bits.iter().fold(0, |acc, &b| (acc << 1) ^ b as usize)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make_map() -> TrenchMap {
        TrenchMap::from_input(
            "..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

#..#.
#....
##..#
..#..
..###",
        )
    }

    #[test]
    fn test_expand_darkness() {
        let trench_map = make_map();
        assert_eq!(trench_map.height, 5);
        assert_eq!(trench_map.width, 5);

        let expanded = trench_map.surround();

        assert_eq!(expanded.height, 7);
        assert_eq!(expanded.width, 7);
        assert_eq!(expanded.get_pixel(0, 0), Pixel::Dark);
        assert_eq!(expanded.get_pixel(6, 6), Pixel::Dark);
    }

    #[test]
    fn get_enhancement_pixel() {
        let trench_map = make_map();
        assert_eq!(trench_map.get_enhancement_pixel(2, 2), Pixel::Light);
        assert_eq!(trench_map.get_enhancement_pixel(0, 0), Pixel::Dark);
    }

    #[test]
    fn enhance_and_count_light() {
        let trench_map = make_map();
        assert_eq!(trench_map.count_light_pixels(), 10);
        assert_eq!(trench_map.enhance().count_light_pixels(), 24);
        assert_eq!(trench_map.enhance().enhance().count_light_pixels(), 35);
    }

    #[test]
    fn enhance_again() {
        let map = TrenchMap::from_input(
            "#..###.##....#.#.#...#.#.#...##...####......##.##..###...#.####..#..#..#####..#.##.....#..#.###.##...#.#.....#...##.##.##...#####.#.#.#.##.###.#.##..#.##.##.#..#...####.#.#.....#..#.....###.#..#.#.#.#...#.###..#.###..##.#..#...##...####.#.........###..#.##.#..#.#...##.#.#.##.####.###....#####..###...##..#####..###..##..#.#.#..###.##.###..#.#######.####..#....###.##...#.####..#.#######...###...##.##.###...##..#.....#.###....#..#.#..###.#...#######.#...##..#.#..##.#...##.#..##.##..#...#.#.##.####........#..#.

#.
##");

        let enhanced = map.enhance();
        assert_eq!(enhanced.edges, Pixel::Light);
        assert_eq!(enhanced.count_light_pixels(), 6);
        assert_eq!(enhanced.enhance().edges, Pixel::Dark);
    }
}

// 000010010
