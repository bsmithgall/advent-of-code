package main

import (
	"fmt"
	"strconv"
	"strings"
)

func DayNine(skip bool) {
	if skip {
		return
	}

	input := ReadLines("day-9")
	instructions := DayNineParse(input)

	fmt.Printf("Distinct tail positions visited (one rope): %d\n", DayNineOne(instructions))
	fmt.Printf("Distinct tail positions visited (ten ropes): %d\n", DayNineTwo(instructions))
}

func DayNineOne(instructions []RopeInstruction) int {
	allPositions := make(map[RopePosition]bool)
	rope := Rope{RopePosition{0, 0}, RopePosition{0, 0}}
	for _, instruction := range instructions {
		moved, positions := rope.Move(instruction)
		rope = moved
		for k, v := range positions {
			allPositions[k] = v
		}
	}

	return len(allPositions)
}

func DayNineTwo(instructions []RopeInstruction) int {
	allPositions := make(map[RopePosition]bool)

	ropes := [10]Rope{}
	for i := range ropes {
		ropes[i] = Rope{RopePosition{0, 0}, RopePosition{0, 0}}
	}

	for _, instruction := range instructions {
		for i := 0; i < instruction.distance; i++ {
			ropes[0].head = ropes[0].head.MoveHead(instruction.direction)
			ropes[0].tail = ropes[0].MoveTail()
			for r := 1; r < len(ropes); r++ {
				ropes[r].head = ropes[r-1].tail
				ropes[r].tail = ropes[r].MoveTail()
			}
			allPositions[ropes[9].head] = true
		}
	}

	return len(allPositions)

}

func DayNineParse(input []string) []RopeInstruction {
	instructions := make([]RopeInstruction, len(input))

	for i, value := range input {
		parts := strings.Split(value, " ")
		distance, _ := strconv.Atoi(parts[1])
		instructions[i] = RopeInstruction{parts[0], distance}
	}

	return instructions
}

type RopePosition struct {
	x, y int
}

type Rope struct {
	head, tail RopePosition
}

type RopeInstruction struct {
	direction string
	distance  int
}

type TailPositions = map[RopePosition]bool

func (r Rope) Move(instruction RopeInstruction) (Rope, TailPositions) {
	positions := make(map[RopePosition]bool)
	for i := 0; i < instruction.distance; i++ {
		r.head = r.head.MoveHead(instruction.direction)
		r.tail = r.MoveTail()
		positions[r.tail] = true
	}

	return r, positions
}

func (r RopePosition) MoveHead(direction string) RopePosition {
	switch direction {
	case "R":
		return RopePosition{r.x + 1, r.y}
	case "L":
		return RopePosition{r.x - 1, r.y}
	case "U":
		return RopePosition{r.x, r.y + 1}
	case "D":
		return RopePosition{r.x, r.y - 1}
	default:
		// no-op
		return r
	}
}

func (r Rope) MoveTail() RopePosition {
	xMove, yMove := 0, 0
	xDist, yDist := r.head.x-r.tail.x, r.head.y-r.tail.y

	if Abs(xDist) > 1 || Abs(yDist) > 1 {
		xMove, yMove = StepCloserToZero(xDist), StepCloserToZero(yDist)
	}

	return RopePosition{r.tail.x + xMove, r.tail.y + yMove}
}

func Abs(x int) int {
	if x < 0 {
		return -x
	}
	return x
}

func StepCloserToZero(x int) int {
	if Abs(x) < 1 {
		return 0
	} else if x < 0 {
		return -1
	}

	return 1
}
