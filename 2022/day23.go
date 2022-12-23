package main

import (
	"fmt"
	"math"
	"reflect"
	"strings"
)

func DayTwentyThree(skip bool) {
	if skip {
		return
	}

	input := Read("day-23")

	fmt.Println("Bounding rect after 10 rounds:", DayTwentyThreeOne(input))
	fmt.Println("Elves stop moving after round: ", DayTwentyThreeTwo(input))
}

func DayTwentyThreeOne(input string) int {
	elves := ToElves(input)

	for i := 0; i < 10; i++ {
		elves.grid = elves.MakeMove()
		elves.stepCount += 1
	}

	return elves.BoundingRect()
}

func DayTwentyThreeTwo(input string) int {
	elves := ToElves(input)
	i := 0

	for {
		i++
		new := elves.MakeMove()
		if reflect.DeepEqual(new, elves.grid) {
			return i
		}
		elves.grid = new
		elves.stepCount += 1
	}
}

type Elves struct {
	grid      map[Point]bool
	stepCount int
}

func (e Elves) AnyNorth(elf Point) bool {
	return e.grid[Point{elf.x - 1, elf.y - 1}] || e.grid[Point{elf.x, elf.y - 1}] || e.grid[Point{elf.x + 1, elf.y - 1}]
}

func (e Elves) AnySouth(elf Point) bool {
	return e.grid[Point{elf.x - 1, elf.y + 1}] || e.grid[Point{elf.x, elf.y + 1}] || e.grid[Point{elf.x + 1, elf.y + 1}]
}

func (e Elves) AnyEast(elf Point) bool {
	return e.grid[Point{elf.x + 1, elf.y - 1}] || e.grid[Point{elf.x + 1, elf.y}] || e.grid[Point{elf.x + 1, elf.y + 1}]
}

func (e Elves) AnyWest(elf Point) bool {
	return e.grid[Point{elf.x - 1, elf.y - 1}] || e.grid[Point{elf.x - 1, elf.y}] || e.grid[Point{elf.x - 1, elf.y + 1}]
}

func (e Elves) AnyNeighbors(elf Point) bool {
	return e.AnyNorth(elf) || e.AnySouth(elf) || e.AnyEast(elf) || e.AnyWest(elf)
}

func (e Elves) Propose(elf Point) Point {
	if !e.AnyNeighbors(elf) {
		return elf
	}

	for i := e.stepCount; i < e.stepCount+4; i++ {
		if i%4 == 0 && !e.AnyNorth(elf) {
			return elf.Add(Point{0, -1})
		}
		if i%4 == 1 && !e.AnySouth(elf) {
			return elf.Add(Point{0, 1})
		}
		if i%4 == 2 && !e.AnyWest(elf) {
			return elf.Add(Point{-1, 0})
		}
		if i%4 == 3 && !e.AnyEast(elf) {
			return elf.Add(Point{1, 0})
		}
	}

	return elf
}

func (e Elves) MakeMove() map[Point]bool {
	proposals := [][2]Point{}
	proposalCounts := make(map[Point]int)
	newGrid := make(map[Point]bool)

	for elf := range e.grid {
		proposal := e.Propose(elf)
		proposals = append(proposals, [2]Point{elf, proposal})
		proposalCounts[proposal] += 1
	}

	for _, proposal := range proposals {
		if proposalCounts[proposal[1]] <= 1 {
			newGrid[proposal[1]] = true
		} else {
			newGrid[proposal[0]] = true
		}
	}

	return newGrid
}

func (e Elves) BoundingRect() int {
	minX, maxX, minY, maxY := 0, 0, 0, 0
	for elf := range e.grid {
		if elf.x < minX {
			minX = elf.x
		}
		if elf.x > maxX {
			maxX = elf.x
		}
		if elf.y < minY {
			minY = elf.y
		}
		if elf.y > maxY {
			maxY = elf.y
		}
	}

	return (maxX-minX+1)*(maxY-minY+1) - len(e.grid)
}

func (e Elves) Min() Point {
	minX, minY := math.MaxInt, math.MaxInt
	for elf := range e.grid {
		if elf.x < minX {
			minX = elf.x
		}
		if elf.y < minY {
			minY = elf.y
		}
	}

	return Point{minX, minY}
}

func (e Elves) Max() Point {
	maxX, maxY := math.MinInt, math.MinInt
	for elf := range e.grid {
		if elf.x > maxX {
			maxX = elf.x
		}
		if elf.y > maxY {
			maxY = elf.y
		}
	}

	return Point{maxX, maxY}

}

func (e Elves) String() string {
	min, max := e.Min(), e.Max()
	output := ""

	for y := min.y; y <= max.y; y++ {
		for x := min.x; x <= max.x; x++ {
			if e.grid[Point{x, y}] {
				output += "#"
			} else {
				output += "."
			}
		}
		output += "\n"
	}

	return output
}

func ToElves(input string) Elves {
	grid := make(map[Point]bool)

	for y, line := range strings.Split(input, "\n") {
		for x, char := range line {
			if char == '#' {
				grid[Point{x, y}] = true
			}
		}
	}

	return Elves{grid, 0}
}
