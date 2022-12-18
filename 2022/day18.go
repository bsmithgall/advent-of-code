package main

import (
	"fmt"
	"math"
)

func DayEighteen(skip bool) {
	if skip {
		return
	}

	input := ReadMatrix("day-18", ",")

	fmt.Println("Scanned droplet surface area", DayEighteenOne(input))
	fmt.Println("Exterior droplet surface area", DayEighteenTwo(input))
}

func DayEighteenOne(input [][]int) int {
	grid := ToCubeGrid(input)
	sa := 0

	for cube := range grid.cubes {
		sa += cube.NumAdjacent(grid)
	}

	return sa
}

func DayEighteenTwo(input [][]int) int {
	grid := ToCubeGrid(input)
	sa := 0
	min := grid.MinCoords().Add(Cube{-2, -2, -2})
	max := grid.MaxCoords().Add(Cube{2, 2, 2})
	filled := make(map[Cube]bool)

	filled = grid.FloodFill(filled, min, max, min)

	for cube := range grid.cubes {
		for _, direction := range Directions {
			_, ok := filled[cube.Add(direction)]
			if ok {
				sa += 1
			}
		}
	}

	return sa
}

type Cube struct{ x, y, z int }

var Directions = []Cube{{-1, 0, 0}, {1, 0, 0}, {0, -1, 0}, {0, 1, 0}, {0, 0, -1}, {0, 0, 1}}

func (c Cube) Add(o Cube) Cube         { return Cube{c.x + o.x, c.y + o.y, c.z + o.z} }
func (c Cube) AnyLessThan(o Cube) bool { return c.x < o.x || c.y < o.y || c.z < o.z }
func (c Cube) AnyMoreThan(o Cube) bool { return c.x >= o.x || c.y >= o.y || c.z >= o.z }
func (c Cube) NumAdjacent(g CubeGrid) int {
	num := 0
	for _, direction := range Directions {
		_, ok := g.cubes[c.Add(direction)]
		if !ok {
			num += 1
		}
	}

	return num
}

type CubeGrid struct{ cubes map[Cube]bool }

// Return a cube with each point representing the minimum value of all cubes in
// the grid
func (g CubeGrid) MinCoords() Cube {
	min := Cube{math.MaxInt, math.MaxInt, math.MaxInt}

	for cube := range g.cubes {
		if cube.x < min.x {
			min.x = cube.x
		}
		if cube.y < min.y {
			min.y = cube.y
		}
		if cube.z < min.z {
			min.z = cube.z
		}
	}

	return min
}

// Return a cube with each point representing the maximum value of all cubes in
// the grid
func (g CubeGrid) MaxCoords() Cube {
	max := Cube{math.MinInt, math.MinInt, math.MinInt}

	for cube := range g.cubes {
		if cube.x > max.x {
			max.x = cube.x
		}
		if cube.y > max.y {
			max.y = cube.y
		}
		if cube.z > max.z {
			max.z = cube.z
		}
	}

	return max
}

// starting from Cube `inspect`, attempt to add all neighboring cubes unless
// they are outside of the grid, along the boundary of the existing grid, or are
// already filled
func (g CubeGrid) FloodFill(filled map[Cube]bool, min Cube, max Cube, inspect Cube) map[Cube]bool {
	if inspect.AnyLessThan(min) || inspect.AnyMoreThan(max) {
		return filled
	} else if g.cubes[inspect] {
		return filled
	} else if filled[inspect] {
		return filled
	} else {
		filled[inspect] = true
		for _, adj := range Directions {
			filled = g.FloodFill(filled, min, max, inspect.Add(adj))
		}
	}

	return filled
}

func ToCubeGrid(matrix [][]int) CubeGrid {
	cubes := make(map[Cube]bool)

	for _, row := range matrix {
		cubes[Cube{row[0], row[1], row[2]}] = true
	}

	return CubeGrid{cubes}
}
