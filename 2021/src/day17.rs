pub fn trick_shot(skip: bool) {
    if !skip {
        // test values
        // let target = Target::from_tup((20, 30), (-5, -10));
        let target = Target::from_tup((287, 309), (-48, -76));
        let mut global_max_y = 0;
        let mut total_target_hits = 0;

        // no need to search past an initial velocity where it goes past the end
        for x in 0..target.end_x + 1 {
            // minimum y velocity would have to be bottom of the target range
            // maximum y velocity is one more than abs(bottom of target) because otherwise it'll
            // go straight through
            for y in target.end_y..((target.end_y - 1).abs()) {
                let mut probe = Probe::new((x, y));
                let max_y = loop {
                    if !probe.could_enter_target_area(&target) {
                        break i32::MIN;
                    }

                    probe = probe.tick();

                    if probe.in_target_area(&target) {
                        total_target_hits += 1;
                        break probe.max_y;
                    }
                };

                if max_y > global_max_y {
                    global_max_y = max_y
                }
            }
        }

        println!("Max y: {}", global_max_y);
        println!("Total possible target hits: {}", total_target_hits);
    }
}

trait Ticker<T> {
    fn tick(&self) -> T;
}

#[derive(Debug, Copy, Clone)]
struct Velocity {
    x: i32,
    y: i32,
}

impl Ticker<Velocity> for Velocity {
    fn tick(&self) -> Velocity {
        Velocity {
            x: if self.x == 0 { 0 } else { self.x.abs() - 1 },
            y: self.y - 1,
        }
    }
}

#[derive(Debug)]
struct Probe {
    velocity: Velocity,
    x: i32,
    y: i32,
    max_y: i32,
    tick: u32,
}

impl Ticker<Probe> for Probe {
    fn tick(&self) -> Probe {
        let new_y = self.y + self.velocity.y;
        let new = Probe {
            velocity: self.velocity.tick(),
            x: self.x + self.velocity.x,
            y: self.y + self.velocity.y,
            max_y: if new_y > self.max_y {
                new_y
            } else {
                self.max_y
            },
            tick: self.tick + 1,
        };

        new
    }
}

impl Probe {
    fn new(initial_velocity: (i32, i32)) -> Probe {
        Probe {
            x: 0,
            y: 0,
            max_y: 0,
            tick: 0,
            velocity: Velocity {
                x: initial_velocity.0,
                y: initial_velocity.1,
            },
        }
    }

    fn in_target_area(&self, target: &Target) -> bool {
        (target.start_x <= self.x && self.x <= target.end_x)
            && (target.start_y >= self.y && self.y >= target.end_y)
    }

    /// check if it's still possible for us to enter the target area.
    /// we could enter the target area if:
    ///   1. we are above the target area
    ///   2a. we are to the left of the right edge of the target area with a positive x velocity
    ///   2b. we are at the right edge of the target area with a 0 x velocity
    fn could_enter_target_area(&self, target: &Target) -> bool {
        (self.y > target.end_y)
            && ((self.x < target.end_x && self.velocity.x >= 0)
                || (self.x == target.end_x - 1 && self.velocity.x == 0))
    }
}

struct Target {
    start_x: i32,
    start_y: i32,
    end_x: i32,
    end_y: i32,
}

impl Target {
    fn from_tup(x: (i32, i32), y: (i32, i32)) -> Target {
        Target {
            start_x: x.0,
            end_x: x.1,
            start_y: y.0,
            end_y: y.1,
        }
    }
}
