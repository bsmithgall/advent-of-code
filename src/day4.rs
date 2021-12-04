pub fn bingo(skip: bool) {
    if !skip {
        let input: Vec<&str> = include_str!("inputs/day-4.txt")
            .split("\n")
            .filter(|line| !line.is_empty())
            .collect();

        let numbers_to_draw: Vec<u32> = input[0]
            .split(",")
            .map(|d| d.parse::<u32>().unwrap())
            .collect();

        let mut bingo_cards = vec![];

        for i in (1..input.len()).step_by(5) {
            bingo_cards.push(BingoCard::from_input(input[i..i + 5].to_vec()))
        }

        for number in numbers_to_draw {
            for card in bingo_cards.iter_mut() {
                if card.winner {
                    continue
                }

                card.mark(number);

                if card.is_bingo() {
                    println!("Winner! {}, {}, {}", card.unmarked_sum(), number, card.unmarked_sum() * number);
                    card.mark_winner(number);
                }
            }
        }
    }
}

#[derive(Copy, Clone)]
struct BingoCell {
    row: usize,
    col: usize,
    value: u32,
    marked: bool,
}

impl BingoCell {
    fn mark(&mut self) {
        self.marked = true
    }
}

struct BingoCard {
    cells: Vec<BingoCell>,
    winner: bool,
    won_at: u32,
}

impl BingoCard {
    fn from_input(input: Vec<&str>) -> BingoCard {
        let mut cells = vec![];
        for (row_idx, row) in input.iter().enumerate() {
            for (col_idx, value) in row.split_whitespace().enumerate() {
                cells.push(BingoCell {
                    row: row_idx,
                    col: col_idx,
                    value: value.parse::<u32>().unwrap(),
                    marked: false,
                })
            }
        }

        BingoCard {
            cells,
            winner: false,
            won_at: u32::MAX,
        }
    }

    fn is_bingo(&self) -> bool {
        for idx in 0..5 {
            // check row
            if self
                .cells
                .iter()
                .filter(|c| c.row == idx && c.marked)
                .count()
                == 5
            {
                return true;
            // check column
            } else if self
                .cells
                .iter()
                .filter(|c| c.col == idx && c.marked)
                .count()
                == 5
            {
                return true;
            }
        }

        false
    }

    fn mark(&mut self, value: u32) {
        if !self.winner {
            for cell in self.cells.iter_mut() {
                if value == cell.value {
                    cell.mark()
                }
            }
        }
    }

    fn mark_winner(&mut self, number: u32) {
        self.winner = true;
        self.won_at = number;
    }

    fn unmarked_sum(&self) -> u32 {
        self.cells
            .iter()
            .filter(|cell| !cell.marked)
            .fold(0, |acc, cell| cell.value + acc)
    }
}
