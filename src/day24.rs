use std::collections::HashMap;

pub fn alu(skip: bool) {
    if !skip {
        let input = include_str!("inputs/day-24.txt");

        let instructions: Vec<Instruction> = input.lines().map(Instruction::from_line).collect();

        let mut parallel_alus: Vec<(ALU, Scores)> = vec![(ALU::default(), Scores::default())];

        for i in instructions {
            match i {
                Instruction::Inp(target) => {
                    let mut new_alus: Vec<(ALU, Scores)> = Vec::new();
                    let mut alu_tracking: HashMap<ALU, usize> = HashMap::new();

                    for (alu, scores) in &parallel_alus {
                        for val in 1..=9 {
                            let mut new_alu = alu.clone();
                            let mut new_scores = scores.clone();
                            new_alu.apply_input(target, val);
                            new_scores.min = new_scores.min * 10 + val as u64;
                            new_scores.max = new_scores.max * 10 + val as u64;

                            if let Some(idx) = alu_tracking.get(&new_alu) {
                                new_alus[*idx].1 = Scores {
                                    min: u64::min(new_alus[*idx].1.min, new_scores.min),
                                    max: u64::max(new_alus[*idx].1.max, new_scores.max),
                                }
                            } else {
                                alu_tracking.insert(new_alu.clone(), new_alus.len());
                                new_alus.push((new_alu, new_scores));
                            }
                        }
                    }
                    parallel_alus = new_alus;
                    println!("Processing {} states...", parallel_alus.len());
                }
                instruction => {
                    for (alu, _) in &mut parallel_alus {
                        alu.apply_operation(instruction);
                    }
                }
            }
        }

        let mut lowest = u64::MAX;
        let mut highest = u64::MIN;

        for (alu, scores) in parallel_alus {
            if !alu.is_valid() {
                continue;
            }

            lowest = lowest.min(scores.min);
            highest = highest.max(scores.max);
        }

        println!("Highest input: {}", highest);
        println!("Lowest input: {}", lowest);
    }
}

#[derive(Default, Clone)]
struct Scores {
    min: u64,
    max: u64,
}

#[derive(Clone, Copy, Debug)]
enum Argument {
    Storage(usize),
    Value(i64),
}

impl Argument {
    fn from_str(input: &str) -> Argument {
        match input {
            "w" => Argument::Storage(0),
            "x" => Argument::Storage(1),
            "y" => Argument::Storage(2),
            "z" => Argument::Storage(3),
            _ => Argument::Value(input.parse::<i64>().expect(input)),
        }
    }

    fn idx(&self) -> usize {
        match self {
            Self::Storage(idx) => *idx,
            Self::Value(_) => unreachable!(),
        }
    }
}

#[derive(Clone, Copy, Debug)]
enum Instruction {
    Inp(usize),
    Add(usize, Argument),
    Mul(usize, Argument),
    Div(usize, Argument),
    Mod(usize, Argument),
    Eql(usize, Argument),
}

impl Instruction {
    fn from_line(line: &str) -> Instruction {
        let mut parts = line.trim().split_whitespace();
        let instruction_str = parts.next().unwrap();
        let arg_one = if let Some(storage_str) = parts.next() {
            Argument::from_str(storage_str)
        } else {
            panic!()
        };

        let arg_two = if let Some(arg_str) = parts.next() {
            Some(Argument::from_str(arg_str))
        } else {
            None
        };

        match instruction_str {
            "inp" => Instruction::Inp(arg_one.idx()),
            "add" => Instruction::Add(arg_one.idx(), arg_two.unwrap()),
            "mul" => Instruction::Mul(arg_one.idx(), arg_two.unwrap()),
            "div" => Instruction::Div(arg_one.idx(), arg_two.unwrap()),
            "mod" => Instruction::Mod(arg_one.idx(), arg_two.unwrap()),
            "eql" => Instruction::Eql(arg_one.idx(), arg_two.unwrap()),
            _ => unreachable!(),
        }
    }
}

#[derive(Debug, Clone, Copy, Hash, Default, Eq, PartialEq)]
struct ALU {
    register: [i64; 4],
}

impl ALU {
    fn apply_input(&mut self, target: usize, val: i64) {
        self.register[target] = val;
    }

    fn apply_operation(&mut self, i: Instruction) {
        match i {
            Instruction::Inp(_) => unreachable!(),
            Instruction::Add(idx, arg) => self.register[idx] += self.get_value(arg),
            Instruction::Mul(idx, arg) => self.register[idx] *= self.get_value(arg),
            Instruction::Div(idx, arg) => self.register[idx] /= self.get_value(arg),
            Instruction::Mod(idx, arg) => self.register[idx] %= self.get_value(arg),
            Instruction::Eql(idx, arg) => {
                self.register[idx] = (self.register[idx] == self.get_value(arg)) as i64
            }
        }
    }

    fn get_value(&self, argument: Argument) -> i64 {
        match argument {
            Argument::Value(v) => v,
            Argument::Storage(idx) => self.register[idx],
        }
    }

    fn is_valid(&self) -> bool {
        self.register[3] == 0
    }
}
