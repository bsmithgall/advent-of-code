import re
import z3
from typing import List, Tuple


def parse(input: str) -> List[Tuple[List[List[int]], List[int]]]:
    out = []
    for line in input.strip().split("\n"):
        buttons = []
        for match in re.finditer(r"\(([0-9,]+)\)", line):
            buttons.append([int(x) for x in match.group(1).split(",")])

        target_match = re.search(r"\{([0-9,]+)\}", line)
        if target_match is None:
            raise Exception("bad input")

        targets = [int(x) for x in target_match.group(1).split(",")]
        out.append((buttons, targets))
    return out


def solve(buttons: List[List[int]], targets: List[int]) -> int:
    opt = z3.Optimize()

    presses = [z3.Int(f"button_{i}") for i in range(len(buttons))]
    [opt.add(c >= 0) for c in presses]

    for idx, target in enumerate(targets):
        opt.add(
            z3.Sum(
                [
                    presses[button_idx]
                    for button_idx, button in enumerate(buttons)
                    if idx in button
                ]
            )
            == target
        )

    total_presses = z3.Sum(presses)
    opt.minimize(total_presses)

    if opt.check() == z3.sat:
        return opt.model().eval(total_presses).as_long()
    else:
        raise Exception("No solution.")


with open("./src/inputs/day_10.txt") as f:
    machines = parse(f.read())

print(sum([solve(m[0], m[1]) for m in machines]))
