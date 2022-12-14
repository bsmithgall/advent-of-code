package main

import (
	"fmt"
	"math"
	"strconv"
	"strings"
)

func DayFourteen(skip bool) {
	if skip {
		return
	}

	input := ReadLines("day-14")

	fmt.Printf("Total resting sand: %d\n", DayFourteenOne(input))
	fmt.Printf("Total resting sand (with floor): %d\n", DayFourteenTwo(input))
}

func DayFourteenOne(input []string) int {
	grid := MakeSandGrid(input, true)
	grid.fill(RockCoord{500, 0}, func(s SandGrid, c RockCoord) bool {
		_, contains := s.coords[c]
		return contains
	})

	return len(grid.coords) - grid.initialFilled
}

func DayFourteenTwo(input []string) int {
	grid := MakeSandGrid(input, false)
	grid.fill(RockCoord{500, 0}, func(s SandGrid, c RockCoord) bool {
		_, contains := s.coords[c]
		return contains || c.y == s.maxY+2
	})
	return len(grid.coords) - grid.initialFilled
}

type RockCoord struct{ x, y int }

func (start RockCoord) FillTo(end RockCoord) []RockCoord {
	filled := []RockCoord{}
	if start.x == end.x {
		direction := Signum(end.y - start.y)
		for i := 0; i <= Abs(end.y-start.y); i++ {
			filled = append(filled, RockCoord{start.x, start.y + (direction * i)})
		}
	} else {
		direction := Signum(end.x - start.x)
		for i := 0; i <= Abs(end.x-start.x); i++ {
			filled = append(filled, RockCoord{start.x + (direction * i), start.y})
		}
	}

	return filled
}

// sparse grid; len(coords) provides number of filled
type SandGrid struct {
	coords        map[RockCoord]bool
	initialFilled int
	maxY          int
	stopAtMaxY    bool
}

func MakeSandGrid(input []string, stopAtYMax bool) SandGrid {
	coords := make(map[RockCoord]bool)
	maxY := math.MinInt

	for _, line := range input {
		parts := strings.Split(line, " -> ")
		for i := 1; i < len(parts); i++ {
			start, end := toRockCoord(parts[i-1]), toRockCoord(parts[i])
			maxY = int(math.Max(math.Max(float64(start.y), float64(end.y)), float64(maxY)))
			for _, coord := range start.FillTo(end) {
				coords[coord] = true
			}
		}
	}

	return SandGrid{coords, len(coords), maxY, stopAtYMax}
}

func toRockCoord(s string) RockCoord {
	parts := strings.Split(s, ",")
	x, _ := strconv.Atoi(parts[0])
	y, _ := strconv.Atoi(parts[1])

	return RockCoord{x, y}
}

func (s SandGrid) fill(start RockCoord, hasCoord func(s SandGrid, c RockCoord) bool) bool {
	if s.stopAtMaxY && start.y > s.maxY {
		return false
	}

	down := RockCoord{start.x, start.y + 1}
	downWest := RockCoord{start.x - 1, start.y + 1}
	downEast := RockCoord{start.x + 1, start.y + 1}

	hasDown := hasCoord(s, down) || s.fill(down, hasCoord)
	hasDownWest := hasDown && (hasCoord(s, downWest) || s.fill(downWest, hasCoord))
	hasDownEast := hasDownWest && (hasCoord(s, downEast) || s.fill(downEast, hasCoord))

	if hasDownEast {
		s.coords[start] = true
		return true
	} else {
		return false
	}
}
