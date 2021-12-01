pub fn run_counts() {
    let input: Vec<i32> = include_str!("day-1-input.txt")
        .split("\n")
        .map(|d| d.parse::<i32>().unwrap())
        .collect();

    println!("Simple comparison count: {}", simple_comparison(&input));
    println!("Sliding window count: {}", sliding_window_count(&input));
}

fn simple_comparison(input: &Vec<i32>) -> i32 {
    let mut greaters = 0;

    for (idx, value) in input.iter().enumerate() {
        if idx == input.len() - 1 {
            continue;
        } else if value < &input[idx + 1] {
            greaters += 1
        }
    }

    greaters
}

fn sliding_window_count(input: &Vec<i32>) -> i32 {
    let mut greaters = 0;

    for (idx, _value) in input.iter().enumerate() {
        // skip if we don't have enough measurements left to create a new three-measurement sum
        if idx < 3 {
            continue;
        } else if make_sum(input, idx - 1) < make_sum(input, idx) {
            greaters += 1
        }
    }

    greaters
}

fn make_sum(input: &Vec<i32>, idx: usize) -> i32 {
    input[idx - 2] + input[idx - 1] + input[idx]
}
