use std::collections::HashMap;

pub fn diagnostics(skip: bool) {
    if !skip {
        // technically we have binary digits but the "decoding" we are doing look
        // a bit more like matrices, so we instead convert the input in a list
        // of lists, where each outer list is a "binary number" and each
        // element of the inner list is a bit of the binary number
        let input: Vec<Vec<i32>> = include_str!("inputs/day-3.txt")
            .split("\n")
            .filter(|line| !line.is_empty())
            .map(|binary| {
                binary
                    .split("")
                    .filter(|c| !c.is_empty())
                    .map(|d| d.parse::<i32>().unwrap())
                    .collect()
            })
            .collect();

        let gamma_rate = calculate_gamma_rate(&input);
        let epsilon_rate = calculate_epsilon_rate(&input);
        let power_consumption = calculate_rating(&gamma_rate, &epsilon_rate);

        println!(
            "Epsilon rate: {:?} ({}), Gamma rate: {:?} ({}), Power consuption: {}",
            epsilon_rate,
            vec_to_int(&epsilon_rate),
            gamma_rate,
            vec_to_int(&gamma_rate),
            power_consumption
        );

        let oxygen_rating = calculate_oxygen_rating(&input);
        let co2_rating = calculate_co2_rating(&input);
        let life_support = calculate_rating(&oxygen_rating, &co2_rating);

        println!(
            "Oxygen rating {:?} ({}), CO2 rating {:?} ({}), Life support: {}",
            oxygen_rating,
            vec_to_int(&oxygen_rating),
            co2_rating,
            vec_to_int(&co2_rating),
            life_support
        )
    }
}

fn calculate_gamma_rate(input: &Vec<Vec<i32>>) -> Vec<i32> {
    input
        .iter()
        .enumerate()
        .filter(|(f, inner)| f < &inner.len())
        .map(|(idx, _)| most_common_bit(input, idx))
        .collect()
}

fn calculate_epsilon_rate(input: &Vec<Vec<i32>>) -> Vec<i32> {
    input
        .iter()
        .enumerate()
        .filter(|(f, inner)| f < &inner.len())
        .map(|(idx, _)| most_common_bit(input, idx))
        .map(|b| if b == 0 { 1 } else { 0 })
        .collect()
}

fn calculate_oxygen_rating(input: &Vec<Vec<i32>>) -> Vec<i32> {
    let mut rating = input.clone();

    for i in 0..input[0].len() {
        let common_bit = most_common_bit(&rating, i);
        rating = rating
            .iter()
            .filter(|f| f[i] == common_bit)
            .cloned()
            .collect();
        if rating.len() == 1 {
            break;
        }
    }

    if rating.len() > 1 {
        panic!("oh no!")
    }

    rating.remove(0)
}

fn calculate_co2_rating(input: &Vec<Vec<i32>>) -> Vec<i32> {
    let mut rating = input.clone();

    for i in 0..input[0].len() {
        let common_bit = most_common_bit(&rating, i);
        rating = rating
            .iter()
            .filter(|f| f[i] != common_bit)
            .cloned()
            .collect();
        if rating.len() == 1 {
            break;
        }
    }

    if rating.len() > 1 {
        panic!("oh no!")
    }

    rating.remove(0)
}

fn most_common_bit(input: &Vec<Vec<i32>>, at: usize) -> i32 {
    let bit_count = input
        .iter()
        .map(|f| f.get(at).expect(&at.to_string()))
        .fold(HashMap::new(), |mut acc, item| {
            *acc.entry(item).or_insert(0) += 1;
            acc
        });

    if bit_count.get(&0).unwrap_or(&0) > bit_count.get(&1).unwrap_or(&0) {
        0
    } else {
        1
    }
}

fn calculate_rating(rate_a: &Vec<i32>, rate_b: &Vec<i32>) -> isize {
    vec_to_int(rate_a) * vec_to_int(rate_b)
}

fn vec_to_int(vec: &Vec<i32>) -> isize {
    let as_str: Vec<String> = vec.iter().map(|x| x.to_string()).collect();
    isize::from_str_radix(&as_str.join(""), 2).unwrap()
}
