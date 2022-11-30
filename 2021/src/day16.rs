pub fn decoder(skip: bool) {
    if !skip {
        let transmission = Transmission::from_hex_input(include_str!("inputs/day-16.txt"));
        let root_packet = transmission.parse_root();

        println!("Sum of versions: {}", root_packet.sum_versions());
        println!("Root packet value: {}", root_packet.operate());
    }
}

type Bits = Vec<u8>;

#[derive(Debug)]
enum LengthType {
    Zero,
    One,
}

#[derive(Debug)]
enum Packet {
    Literal {
        version: u64,
        type_id: u64,
        value: u64,
    },
    Operator {
        version: u64,
        type_id: u64,
        subpackets: Vec<Packet>,
    },
}

impl Packet {
    fn sum_versions(&self) -> u64 {
        match &self {
            Packet::Literal { version, .. } => *version,
            Packet::Operator {
                version,
                subpackets,
                ..
            } => {
                *version
                    + subpackets
                        .iter()
                        .map(|packet| packet.sum_versions())
                        .sum::<u64>()
            }
        }
    }

    fn operate(&self) -> u64 {
        match &self {
            Packet::Literal { value, .. } => *value,
            Packet::Operator {
                type_id,
                subpackets,
                ..
            } => match type_id {
                0 => subpackets.iter().map(|p| p.operate()).sum(),
                1 => subpackets.iter().map(|p| p.operate()).product(),
                2 => subpackets.iter().map(|p| p.operate()).min().unwrap(),
                3 => subpackets.iter().map(|p| p.operate()).max().unwrap(),
                5 => (subpackets[0].operate() > subpackets[1].operate()) as u64,
                6 => (subpackets[0].operate() < subpackets[1].operate()) as u64,
                7 => (subpackets[0].operate() == subpackets[1].operate()) as u64,
                _ => unreachable!("Found an invalid type ID here!"),
            },
        }
    }
}

fn bits_to_u64(bits: &[u8]) -> u64 {
    bits.iter().fold(0, |acc, &b| (acc << 1) ^ b as u64)
}

struct Transmission {
    transmission_bits: Bits,
}

impl Transmission {
    fn from_hex_input(input: &str) -> Transmission {
        Transmission {
            transmission_bits: input
                .chars()
                .flat_map(|c| Transmission::lookup(c).to_vec())
                .collect(),
        }
    }

    fn lookup(c: char) -> [u8; 4] {
        match c {
            '0' => [0, 0, 0, 0],
            '1' => [0, 0, 0, 1],
            '2' => [0, 0, 1, 0],
            '3' => [0, 0, 1, 1],
            '4' => [0, 1, 0, 0],
            '5' => [0, 1, 0, 1],
            '6' => [0, 1, 1, 0],
            '7' => [0, 1, 1, 1],
            '8' => [1, 0, 0, 0],
            '9' => [1, 0, 0, 1],
            'A' => [1, 0, 1, 0],
            'B' => [1, 0, 1, 1],
            'C' => [1, 1, 0, 0],
            'D' => [1, 1, 0, 1],
            'E' => [1, 1, 1, 0],
            'F' => [1, 1, 1, 1],
            _ => unreachable!("Could not find lookup for this character!"),
        }
    }

    fn parse_root(&self) -> Packet {
        let (packet, _) = self.parse_packet(&self.transmission_bits);
        packet
    }

    fn parse_packet(&self, bits: &Bits) -> (Packet, usize) {
        let header_len = 6;
        let version = bits_to_u64(&bits[0..3]);
        let type_id = bits_to_u64(&bits[3..6]);
        match type_id {
            4 => {
                let (value, size) = self.parse_literal(&bits[header_len..].to_vec());
                (
                    Packet::Literal {
                        version,
                        type_id,
                        value,
                    },
                    size + header_len,
                )
            }
            _ => {
                let (subpackets, size) = self.parse_operator(&bits[header_len..].to_vec());
                (
                    Packet::Operator {
                        version,
                        type_id,
                        subpackets,
                    },
                    size + header_len,
                )
            }
        }
    }

    /// parse out the value of the literal packet and return it so we can
    /// build a Packet::Literal. Also returns out the size of the packet
    fn parse_literal(&self, bits: &Bits) -> (u64, usize) {
        let mut value_bits: Bits = vec![];
        let mut pos = 0;
        let mut scan = true;

        while scan {
            if bits[pos] == 0 {
                scan = false;
            }
            let start = pos + 1;
            let end = pos + 5;
            value_bits.extend(&bits[start..end]);
            pos += 5;
        }

        (bits_to_u64(&value_bits), pos)
    }

    /// parse all subpackets contained inside of an operator packet
    fn parse_operator(&self, bits: &Bits) -> (Vec<Packet>, usize) {
        let mut subpackets = vec![];

        let (length_type, mut pos, len) = if bits[0] == 0 {
            (LengthType::Zero, 16, bits_to_u64(&bits[1..16]) as usize)
        } else {
            (LengthType::One, 12, bits_to_u64(&bits[1..12]) as usize)
        };

        let mut scan = true;

        while scan {
            let (packet, size) = self.parse_packet(&bits[pos..].to_vec());
            subpackets.push(packet);
            pos += size;

            scan = match length_type {
                LengthType::Zero => pos - 16 < len,
                LengthType::One => subpackets.len() < len,
            }
        }

        (subpackets, pos)
    }
}
