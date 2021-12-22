use std::{collections::HashMap, time::Instant};

pub fn dirac(skip: bool) {
    if !skip {
        let starting_positions = [1, 6];
        let mut simple_game = SimpleGame::new(starting_positions);

        while !simple_game.completed {
            simple_game.take_turn();
        }

        println!(
            "Loser score * total die rolls: {}",
            simple_game.loser_score() * simple_game.die.times_rolled
        );

        let now = Instant::now();
        let mut quantum_game = QuantumGame::new(starting_positions);
        while !quantum_game.completed {
            quantum_game.take_turn();
        }

        println!(
            "Most wins in all quantum universes: {}",
            quantum_game.most_wins()
        );
        println!("Took {}ms", now.elapsed().as_millis());
    }
}

#[derive(Debug, Clone, Copy, Hash, PartialEq, Eq)]
struct Player {
    position: u64,
    score: u64,
    winner: bool,
}

impl Player {
    fn new(position: &u64) -> Player {
        Player {
            position: position.clone(),
            score: 0,
            winner: false,
        }
    }

    fn take_turn(&mut self, roll_amt: u64) {
        let new_position = (self.position + roll_amt) % 10;
        let new_score = self.score + (if new_position == 0 { 10 } else { new_position });
        self.position = new_position;
        self.score = new_score;
    }
}

// =============== Part One ===============

#[derive(Debug)]
struct SimpleGame {
    turn_number: u64,
    players: [Player; 2],
    completed: bool,
    die: DeterministicDie,
}

impl SimpleGame {
    fn new(starting_positions: [u64; 2]) -> SimpleGame {
        let players = [
            Player::new(&starting_positions[0]),
            Player::new(&starting_positions[1]),
        ];

        SimpleGame {
            turn_number: 0,
            players,
            completed: false,
            die: DeterministicDie::new(),
        }
    }

    fn take_turn(&mut self) -> bool {
        self.turn_number += 1;
        for player in self.players.iter_mut() {
            let roll_amt = self.die.roll(3);
            player.take_turn(roll_amt);
            if player.score >= 1000 {
                player.winner = true;
                self.completed = true;
                return true;
            }
        }

        false
    }

    fn loser_score(&self) -> u64 {
        let loser = if self.players[0].winner {
            self.players[1]
        } else {
            self.players[0]
        };
        loser.score
    }
}

#[derive(Copy, Clone, Debug)]
struct DeterministicDie {
    current_value: u64,
    times_rolled: u64,
}

impl DeterministicDie {
    fn new() -> DeterministicDie {
        DeterministicDie {
            current_value: 0,
            times_rolled: 0,
        }
    }

    fn roll(&mut self, times: u8) -> u64 {
        let mut value = 0;
        for _ in 0..times {
            self.next();
            value += self.current_value;
        }
        value
    }

    fn next(&mut self) {
        self.current_value = if self.current_value == 100 {
            1
        } else {
            self.current_value + 1
        };
        self.times_rolled += 1;
    }
}

// =============== Part Two ===============

#[derive(Debug, Hash, Eq, PartialEq, Clone, Copy)]
struct GameState {
    players: [Player; 2],
}

impl GameState {
    fn from_positions(positions: [u64; 2]) -> GameState {
        let players = [Player::new(&positions[0]), Player::new(&positions[1])];
        GameState { players }
    }
}

struct QuantumGame {
    universes: HashMap<GameState, u64>,
    playing_universes: u64,
    win_count: [u64; 2],
    completed: bool,
}

impl QuantumGame {
    /// There's no need for a quantum die struct. Because the quantum die only has
    /// three sides, we know the possible number of cases that can come out of any given combination
    /// of rolls.
    const ROLLS: [(u64, u64); 7] = [(3, 1), (4, 3), (5, 6), (6, 7), (7, 6), (8, 3), (9, 1)];

    fn new(starting_positions: [u64; 2]) -> QuantumGame {
        let mut universes = HashMap::new();
        universes.insert(GameState::from_positions(starting_positions), 1);
        QuantumGame {
            universes,
            playing_universes: 1,
            win_count: [0, 0],
            completed: false,
        }
    }

    fn take_turn(&mut self) {
        self.take_turn_for_player(0);
        self.take_turn_for_player(1);
        if self.playing_universes == 0 {
            self.completed = true;
        }
    }

    /// For each player that we have, go through all existing universes, move that player
    /// by each possible roll amount based on our three-sided day. If the player hasn't
    /// scored >= 21, take the new number of universes that have been created and add
    /// those into our universes map
    fn take_turn_for_player(&mut self, player: usize) {
        let mut new_universes = HashMap::new();

        self.universes.iter().for_each(|(state, state_count)| {
            self.playing_universes -= state_count;

            QuantumGame::ROLLS.iter().for_each(|(roll, roll_count)| {
                let mut new_state = state.clone();
                new_state.players[player].take_turn(*roll);
                let new_universe_count = roll_count * state_count;

                if new_state.players[player].score >= 21 {
                    self.win_count[player] += new_universe_count;
                } else {
                    let other_count = new_universes.entry(new_state).or_insert(0);
                    *other_count += new_universe_count;
                    self.playing_universes += new_universe_count;
                }
            })
        });

        self.universes = new_universes;
    }

    fn most_wins(&self) -> u64 {
        self.win_count[0].max(self.win_count[1])
    }
}
