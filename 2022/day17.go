package main

import (
	"fmt"
)

func DaySeventeen(skip bool) {
	if skip {
		return
	}

	input := Read("day-17")

	fmt.Println("Max height after 2022 rounds: ", DaySeventeenOne(input, 2022))
	fmt.Println("Max height after 1000000000000 rounds: ", DaySeventeenTwo(input, 1000000000000))
}

func DaySeventeenOne(input string, iters int) int {
	i := 0
	dirIdx := 0
	chamber := EmptyChamber()

	for i < iters {
		rockShape := RockShapes[i%5]
		dirIdx = chamber.DropRock(input, dirIdx, rockShape)
		i++
	}

	return chamber.maxHeight
}

func DaySeventeenTwo(input string, iters int) int {
	seen := make(map[ChamberSignature]SignatureValue)
	i := 0
	dirIdx := 0
	heightOffset := 0
	ffwd := false
	chamber := EmptyChamber()

	for i < iters {
		rockShape := RockShapes[i%5]
		dirIdx = chamber.DropRock(input, dirIdx, rockShape)

		signature := ChamberSignature{i % 5, dirIdx, chamber.String(1)}
		prev, ok := seen[signature]
		if !ffwd {
			if ok {
				// detected a cycle!
				cycleLength := i - prev.i

				// we don't want to skip all the way to the end, we just want to fast
				// forward past the vast majority of the cycles but manually calculate
				// the remaining overhead
				skips := iters/cycleLength - 2

				i += skips * cycleLength
				heightOffset += skips * (chamber.maxHeight - prev.height)
				ffwd = true
			} else {
				seen[signature] = SignatureValue{chamber.maxHeight, i}
			}
		}

		i++
	}

	return chamber.maxHeight + heightOffset
}

type RockShape []Point

var RockShapes = [5]RockShape{
	{{0, 0}, {1, 0}, {2, 0}, {3, 0}},         // -
	{{1, 0}, {0, 1}, {1, 1}, {2, 1}, {1, 2}}, // +
	{{0, 0}, {1, 0}, {2, 0}, {2, 1}, {2, 2}}, // _|
	{{0, 0}, {0, 1}, {0, 2}, {0, 3}},         // |
	{{0, 0}, {1, 0}, {0, 1}, {1, 1}},         // square
}

type Chamber struct {
	rocks     map[Point]bool
	maxHeight int
}

// not sure if this is enough for things to be actually unique, but it does work
// for my input...
type ChamberSignature struct {
	rockShape, dirIdx int
	topRow            string
}

type SignatureValue struct{ height, i int }

func (c Chamber) SpawnRock() Point {
	return Point{2, c.maxHeight + 4}
}

func (c *Chamber) LandRock(curPoint Point, shape RockShape) {
	for _, point := range shape {
		rockPoint := point.Add(curPoint)
		c.rocks[rockPoint] = true
		if rockPoint.y > c.maxHeight {
			c.maxHeight = rockPoint.y
		}
	}
}

func (c *Chamber) DropRock(input string, dirIdx int, rockShape []Point) int {
	rockPos := c.SpawnRock()

	for {
		// handle pushing from side to side
		if input[dirIdx] == '>' && !c.Collision(rockPos.Add(Point{1, 0}), rockShape) {
			rockPos = rockPos.Add(Point{1, 0})
		}
		if input[dirIdx] == '<' && !c.Collision(rockPos.Add(Point{-1, 0}), rockShape) {
			rockPos = rockPos.Add(Point{-1, 0})
		}

		dirIdx = (dirIdx + 1) % len(input)

		// handle dropping down
		if c.Collision(rockPos.Add(Point{0, -1}), rockShape) {
			c.LandRock(rockPos, rockShape)
			break
		}

		rockPos = rockPos.Add(Point{0, -1})
	}

	return dirIdx

}

func (c Chamber) Collision(curPoint Point, shape RockShape) bool {
	for _, point := range shape {
		rockPoint := point.Add(curPoint)
		_, inChamber := c.rocks[rockPoint]
		if inChamber || rockPoint.x < 0 || rockPoint.x > 6 {
			return true
		}
	}
	return false
}

func (c Chamber) String(lastN int) string {
	out := ""
	for y := c.maxHeight; y >= Max(c.maxHeight-lastN, 0); y-- {
		for x := 0; x < 7; x++ {
			_, inChamber := c.rocks[Point{x, y}]
			if inChamber {
				out += "#"
			} else {
				out += "."
			}
		}
		out += "\n"
	}

	return out
}

func EmptyChamber() Chamber {
	rocks := make(map[Point]bool)
	for i := 0; i < 7; i++ {
		rocks[Point{i, 0}] = true
	}

	return Chamber{rocks, 0}
}
