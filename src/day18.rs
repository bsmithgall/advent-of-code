pub fn snailfish(skip: bool) {
    if !skip {
        let input = include_str!("inputs/day-18.txt");
        println!("Combined magnitude: {}", combined_magnitude(input));
        println!(
            "Largest magnitude of any two lines: {}",
            largest_two_numbers(input)
        );
    }
}

fn combined_magnitude(input: &str) -> u32 {
    let mut number = SnailfishNumber::new();
    input.lines().for_each(|line| number.add_from_line(line));
    number.magnitude()
}

fn largest_two_numbers(input: &str) -> u32 {
    let mut largest_magnitude = 0;

    let lines: Vec<&str> = input.split("\n").collect();

    for x_line in 0..lines.len() {
        for y_line in 0..lines.len() {
            if x_line == y_line {
                continue;
            }

            let two_line_magnitude = magnitude_of_lines(lines[x_line], lines[y_line]);
            if two_line_magnitude > largest_magnitude {
                largest_magnitude = two_line_magnitude
            }
        }
    }

    largest_magnitude
}

fn magnitude_of_lines(l1: &str, l2: &str) -> u32 {
    let mut n1 = SnailfishNumber::new();
    n1.add_from_line(l1);
    n1.add_from_line(l2);
    let n1_magnitude = n1.magnitude();

    let mut n2 = SnailfishNumber::new();
    n2.add_from_line(l2);
    n2.add_from_line(l1);
    let n2_magnitude = n2.magnitude();

    if n1_magnitude > n2_magnitude {
        n1_magnitude
    } else {
        n2_magnitude
    }
}

/// instead of implementing as a tree, we can instead
/// keep track of each digit and its relative depth in the
/// nesting. this allows us to sidestep annoyances in the borrow
/// checker in a cute way, and more easily parse the input values
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
struct SnailfishDigit {
    value: u32,
    depth: i8,
}

impl SnailfishDigit {
    fn split(&self) -> (SnailfishDigit, SnailfishDigit) {
        let half = self.value / 2;
        (
            SnailfishDigit {
                value: half,
                depth: self.depth + 1,
            },
            SnailfishDigit {
                value: half + (self.value % 2),
                depth: self.depth + 1,
            },
        )
    }

    fn calc_pair_magnitude(&self, right: &SnailfishDigit) -> Option<SnailfishDigit> {
        if self.depth == right.depth {
            Some(SnailfishDigit {
                value: self.value * 3 + right.value * 2,
                depth: self.depth - 1,
            })
        } else {
            None
        }
    }
}

#[derive(Debug, PartialEq, Eq)]
struct SnailfishNumber {
    digits: Vec<SnailfishDigit>,
}

impl SnailfishNumber {
    fn new() -> Self {
        Self { digits: vec![] }
    }

    fn add_from_line(&mut self, input: &str) {
        // adding another line of input pushes the existing number into the
        // left side of a new snailfish number, so start by incrementing all
        // digits by depth one
        for n in &mut self.digits {
            n.depth += 1
        }

        // now, get the starting nesting level
        let mut nesting_level = if self.digits.is_empty() { 0 } else { 1 };

        for c in input.chars() {
            match c {
                ',' => (),
                '[' => nesting_level += 1,
                ']' => nesting_level -= 1,
                _ => {
                    self.digits.push(SnailfishDigit {
                        value: c.to_digit(10).unwrap(),
                        depth: nesting_level,
                    });
                }
            }
        }

        self.reduce();
    }

    /// Given a snailfish number, reduce it by exploding from left to right, then splitting from
    /// left to right and re-applying those rules until they no longer apply.
    fn reduce(&mut self) {
        loop {
            if self.explode_first() {
                continue;
            }
            if self.split_first() {
                continue;
            }
            break;
        }
    }

    /// Explode at the first valid instance from the left. Returns false if no explosions happen.
    fn explode_first(&mut self) -> bool {
        for (idx, d) in self.digits.iter().enumerate() {
            if d.depth >= 5 {
                self.explode(idx);
                return true;
            }
        }
        false
    }

    /// Split at the first valid instance from the left. Returns false if no splits happen.
    fn split_first(&mut self) -> bool {
        for (idx, d) in self.digits.iter().enumerate() {
            if d.value >= 10 {
                self.split(idx);
                return true;
            }
        }
        false
    }

    fn explode(&mut self, at: usize) {
        // add the pair's left value to the first regular number on its left (if any)
        if at > 0 {
            self.digits[at - 1] = SnailfishDigit {
                value: self.digits[at - 1].value + self.digits[at].value,
                depth: self.digits[at - 1].depth,
            }
        }
        // add the pair's right value to the first regular number on its right (if any)
        if at < self.digits.len() - 2 {
            self.digits[at + 2] = SnailfishDigit {
                value: self.digits[at + 2].value + self.digits[at + 1].value,
                depth: self.digits[at + 2].depth,
            }
        }
        // the pair becomes regular number zero. this means that we set its value to zero,
        // reduce its nesting by one, and remove the value one to the right of it (as it no longer exists)
        self.digits[at] = SnailfishDigit {
            value: 0,
            depth: self.digits[at].depth - 1,
        };
        self.digits.remove(at + 1);
    }

    fn split(&mut self, at: usize) {
        let (left, right) = self.digits[at].split();
        self.digits[at] = left;
        self.digits.insert(at + 1, right);
    }

    /// since we aren't using a tree, we are going to have be very creative in how we compute
    /// the magnitude.
    ///
    /// Here's how this works:
    /// 1. We push our digits onto a stack.
    /// 2. Once we have at least two digits on the stack, we evaluate the second-to-last and last digit
    ///    as a possible pair. If they are a pair, we combine them into a single value using
    ///    Digit::combine and remove the right-most digit off the stack. This happens until all
    ///    possible pairs have been consumed.
    /// 3. Once all possible pairs have been consumed and the whole of the digits have been, the last remaining
    ///    combined number is the digit whose value is the magnitude
    fn magnitude(&self) -> u32 {
        let mut stack = vec![];

        for d in &self.digits {
            stack.push(*d);
            while stack.len() >= 2 {
                let len = stack.len();
                if let Some(combined) = stack[len - 2].calc_pair_magnitude(&stack[len - 1]) {
                    stack[len - 2] = combined;
                    stack.pop();
                } else {
                    break;
                }
            }
        }

        stack.last().unwrap().value
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn parse(input: &str) -> SnailfishNumber {
        let mut n = SnailfishNumber::new();
        n.add_from_line(input);
        n
    }

    #[test]
    fn parse_add() {
        let left = "[1,2]";
        let right = "[[3,4],5]";
        let mut n = SnailfishNumber::new();
        n.add_from_line(left);
        n.add_from_line(right);
        assert_eq!(n, parse("[[1,2],[[3,4],5]]"));
    }

    #[test]
    fn test_explode_one() {
        let mut n = SnailfishNumber::new();
        n.add_from_line("[[[[[9,8],1],2],3],4]");
        assert_eq!(n, parse("[[[[0,9],2],3],4]"));
    }

    #[test]
    fn test_explode_two() {
        let mut n = SnailfishNumber::new();
        n.add_from_line("[7,[6,[5,[4,[3,2]]]]]");
        assert_eq!(n, parse("[7,[6,[5,[7,0]]]]"));
    }

    #[test]
    fn test_explode_three() {
        let mut n = SnailfishNumber::new();
        n.add_from_line("[[6,[5,[4,[3,2]]]],1]");
        assert_eq!(n, parse("[[6,[5,[7,0]]],3]"));
    }
}
