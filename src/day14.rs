use std::collections::HashMap;

pub fn polymerization(skip: bool) {
    if !skip {
        let input_parts: Vec<&str> = include_str!("inputs/day-14.txt")
            .split("\n\n")
            .collect();

        let rules: InsertionRule = input_parts[1]
            .split("\n")
            .fold(HashMap::new(), |mut acc, f| {
                let rule_parts: Vec<char> = f.replace(" -> ", "").chars().collect();
                acc.insert((rule_parts[0], rule_parts[1]), rule_parts[2]);
                acc
            });

        let mut polymeraze: Polymeraze = Polymeraze::from_template(input_parts[0], rules);

        let mut step: u8 = 0;

        while step < 40 {
            polymeraze.polymerize();
            step += 1;
        }

        println!("Most - least: {}", &polymeraze.most_minus_least());
    }
}

type InsertionRule = HashMap<(char, char), char>;
type Pair = (char, char);

#[derive(Debug)]
struct Polymeraze {
    chain: HashMap<Pair, u64>,
    counts: HashMap<char, u64>,
    rules: InsertionRule,
}

impl Polymeraze {
    fn from_template(template: &str, rules: InsertionRule) -> Polymeraze {
        let mut chain = HashMap::new();
        let mut counts = HashMap::new();

        let char_vec: Vec<char> = template.chars().collect();

        for idx in 1..char_vec.len() {
            let (prev, current) = (char_vec[idx - 1], char_vec[idx]);
            *chain.entry((prev, current)).or_insert(0) += 1;
            *counts.entry(prev).or_insert(0) += 1;
        }

        *counts
            .entry(*char_vec.last().expect("Empty char vec!"))
            .or_insert(0) += 1;

        Polymeraze {
            chain,
            counts,
            rules,
        }
    }

    /// We have a chain (represented as a map of two characters + a count) and rules. For each
    /// element in the chain, we need to apply the rule that many times. For example, if we have
    /// the rule AB -> C and AB: 5 in the chain, we need add five to the chain's "AC" key, plus
    /// increment the count of C five times.
    ///
    /// Note that according to the rules, the last Pair does not get a new value added, so
    /// we need to account for that as well.
    fn polymerize(&mut self) {
        let mut new_chain: HashMap<(char, char), u64> = HashMap::new();

        for (k, v) in self.chain.iter() {
            // get our new intermediate value from our rule set
            let applied_value = self
                .rules
                .get(&k)
                .expect("Could not find a value for this rule!");
            // if the key we are looking at is the current last value, update to a new
            // last value of (applied_value, k.1), and move the last value over to the new
            // chain, since it won't otherwise be caught
            // add the new entry of (k.0, applied_value) to the chain
            *new_chain.entry((k.0, applied_value.clone())).or_insert(0) += *v;
            *new_chain.entry((applied_value.clone(), k.1)).or_insert(0) += *v;
            // add the value that we get from the rule to the counts the number of times that this key exists
            // in the chain
            *self.counts.entry(applied_value.clone()).or_insert(0) += *v;
        }

        self.chain = new_chain;
    }

    fn most_minus_least(&self) -> u64 {
        self.counts.values().max().expect("Empty chain!")
            - self.counts.values().min().expect("Empty chain!")
    }
}
