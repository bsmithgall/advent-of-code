package main

import (
	"fmt"
	"math"
	"strings"
)

func DayTwelve(skip bool) {
	if skip {
		return
	}

	input := Read("day-12")
	grid := DayTwelveParse(input)

	fmt.Printf("Steps to end: %d\n", DayTwelveOne(grid))
	fmt.Printf("Steps to end (all possible grids): %d\n", DayTwelveTwo(DayTwelveParse(input)))
}

func DayTwelveOne(input ElevationGrid) int {
	searchResults := input.Bfs()

	return searchResults[input.end]
}

func DayTwelveTwo(input ElevationGrid) int {
	minSteps := math.MaxInt
	possibleGrids := []ElevationGrid{}

	for coord, val := range input.coords {
		if val == 'a' {
			possibleGrids = append(possibleGrids, ElevationGrid{input.coords, coord, input.end})
		}
	}

	for _, grid := range possibleGrids {
		result := grid.Bfs()
		if result[grid.end] < minSteps && result[grid.end] > 0 {
			minSteps = result[grid.end]
		}
	}

	return minSteps
}

type ElevationCoord struct {
	x, y int
}

type ElevationGrid struct {
	coords map[ElevationCoord]rune
	start  ElevationCoord
	end    ElevationCoord
}

func DayTwelveParse(input string) ElevationGrid {
	coords := make(map[ElevationCoord]rune)
	start := ElevationCoord{}
	end := ElevationCoord{}

	rows := strings.Split(input, "\n")

	for idy, row := range rows {
		for idx, col := range row {
			if string(col) == "S" {
				coords[ElevationCoord{idx, idy}] = 'a'
				start = ElevationCoord{idx, idy}
			} else if string(col) == "E" {
				coords[ElevationCoord{idx, idy}] = 'z'
				end = ElevationCoord{idx, idy}
			} else {
				coords[ElevationCoord{idx, idy}] = col
			}
		}
	}

	return ElevationGrid{coords, start, end}
}

func (g ElevationGrid) Neighbors(c ElevationCoord) []ElevationCoord {
	neighbors := []ElevationCoord{}

	// up
	_, upOk := g.coords[ElevationCoord{c.x, c.y + 1}]
	if upOk {
		neighbors = append(neighbors, ElevationCoord{c.x, c.y + 1})
	}

	// down
	_, downOk := g.coords[ElevationCoord{c.x, c.y - 1}]
	if downOk {
		neighbors = append(neighbors, ElevationCoord{c.x, c.y - 1})
	}

	// left
	_, leftOk := g.coords[ElevationCoord{c.x - 1, c.y}]
	if leftOk {
		neighbors = append(neighbors, ElevationCoord{c.x - 1, c.y})
	}

	// right
	_, rightOk := g.coords[ElevationCoord{c.x + 1, c.y}]
	if rightOk {
		neighbors = append(neighbors, ElevationCoord{c.x + 1, c.y})
	}

	return neighbors
}

func (g ElevationGrid) climbable(coord ElevationCoord, other ElevationCoord) bool {
	return g.coords[other]-g.coords[coord] <= 1
}

func (g ElevationGrid) Bfs() map[ElevationCoord]int {
	visited := make(map[ElevationCoord]int)
	toVisit := []ElevationCoord{g.start}
	visited[g.start] = 0

	for len(toVisit) > 0 {
		visiting, rest := toVisit[0], toVisit[1:]
		toVisit = rest
		steps := visited[visiting]

		for _, neighbor := range g.Neighbors(visiting) {
			_, alreadyVisited := visited[neighbor]
			if g.climbable(visiting, neighbor) && !alreadyVisited {
				visited[neighbor] = steps + 1
				toVisit = append(toVisit, neighbor)
			}
		}
	}

	return visited
}
