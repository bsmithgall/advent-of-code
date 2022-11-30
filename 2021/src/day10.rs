pub fn check_syntax(skip: bool) {
    if !skip {
        let lines: Vec<(Option<u32>, Option<Vec<char>>)> = include_str!("inputs/day-10.txt")
            .split("\n")
            .map(|line| parse_line(line))
            .collect();

        let corrupt_score: &u32 = &lines
            .iter()
            .filter_map(|(corrupt_score, _)| match corrupt_score {
                Some(x) => Some(x),
                _ => None,
            })
            .sum();

        let mut incomplete_scores: Vec<u64> = lines
            .iter()
            .filter_map(|(_, incompletes)| match incompletes {
                Some(x) => Some(x),
                _ => None,
            })
            .map(|incomplete| incomplete.into_iter().map(char::complete).rev().collect())
            .map(|complete| score(&complete))
            .collect::<Vec<u64>>();

        incomplete_scores.sort();
        let mid = incomplete_scores.len() / 2;

        println!("Corrupt line score: {}", corrupt_score);
        println!("Incomplete line score: {}", incomplete_scores[mid]);
    }
}

enum Bracket {
    Open(char),
    Close(char),
}

impl Bracket {
    fn from_char(c: char) -> Option<Bracket> {
        match c {
            '{' | '[' | '(' | '<' => Some(Bracket::Open(c)),
            ')' => Some(Bracket::Close('(')),
            ']' => Some(Bracket::Close('[')),
            '}' => Some(Bracket::Close('{')),
            '>' => Some(Bracket::Close('<')),
            _ => None,
        }
    }
}

trait BracketSyntaxChecker<S> {
    fn corrupt_score(&self) -> u32;
    fn complete(&self) -> S;
    fn incomplete_score(&self) -> u64;
}

impl BracketSyntaxChecker<char> for char {
    fn corrupt_score(&self) -> u32 {
        match self {
            '(' => 3,
            '[' => 57,
            '{' => 1197,
            '<' => 25137,
            _ => unreachable!("Could not score invalid close character!"),
        }
    }

    fn complete(&self) -> char {
        match self {
            '(' => ')',
            '[' => ']',
            '{' => '}',
            '<' => '>',
            _ => unreachable!("Invalid open character!"),
        }
    }

    fn incomplete_score(&self) -> u64 {
        match self {
            ')' => 1,
            ']' => 2,
            '}' => 3,
            '>' => 4,
            _ => unreachable!("Invalid close character!"),
        }
    }
}

fn parse_line(string: &str) -> (Option<u32>, Option<Vec<char>>) {
    let mut brackets: Vec<char> = vec![];
    for c in string.chars() {
        match Bracket::from_char(c) {
            Some(Bracket::Open(open_char)) => brackets.push(open_char),
            Some(Bracket::Close(close_char)) => {
                if brackets.pop() != Some(close_char) {
                    return (Some(close_char.corrupt_score()), None);
                }
            }
            _ => {}
        }
    }

    (None, Some(brackets))
}

fn score(complete: &Vec<char>) -> u64 {
    complete
        .iter()
        .fold(0, |acc, &c| (acc * 5) + &c.incomplete_score())
}
