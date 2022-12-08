package main

import "fmt"

func DayEight(skip bool) {
	if skip {
		return
	}

	input := ReadMatrix("day-8", "")
	fmt.Printf("Visible trees: %d\n", DayEightOne(input))
	fmt.Printf("Max eaves score: %d\n", DayEightTwo(input))
}

func DayEightOne(input [][]int) int {
	grid := MakeTreeGrid(input)
	visibleTrees := 0

	for coord := range grid.trees {
		if grid.IsVisible(coord) {
			visibleTrees += 1
		}
	}

	return visibleTrees
}

func DayEightTwo(input [][]int) int {
	grid := MakeTreeGrid(input)
	maxScore := 0

	// grid.EaveScore(TreeCoordinate{2, 1})

	for coord := range grid.trees {
		coordScore := grid.EaveScore(coord)
		if coordScore > maxScore {
			maxScore = coordScore
		}
	}

	return maxScore
}

type TreeCoordinate struct {
	x int
	y int
}

type TreeGrid struct {
	size  int
	trees map[TreeCoordinate]int
}

func MakeTreeGrid(input [][]int) TreeGrid {
	trees := make(map[TreeCoordinate]int)

	for row := 0; row < len(input); row++ {
		for col := 0; col < len(input); col++ {
			trees[TreeCoordinate{col, row}] = input[row][col]
		}
	}

	return TreeGrid{len(input), trees}
}

type Direction int

const (
	N Direction = iota
	S
	E
	W
)

func (g TreeGrid) IsPerimeter(t TreeCoordinate) bool {
	return t.x == 0 || t.y == 0 || t.x == g.size-1 || t.y == g.size-1
}

func (g TreeGrid) IsVisible(t TreeCoordinate) bool {
	if g.IsPerimeter(t) {
		return true
	}

	neighbors := g.Neighbors(t)
	for _, n := range neighbors {
		maxHeight := 0
		for _, height := range n {
			if height > maxHeight {
				maxHeight = height
			}
		}
		if g.trees[t] > maxHeight {
			return true
		}
	}

	return false
}

func (g TreeGrid) EaveScore(t TreeCoordinate) int {
	if g.IsPerimeter(t) {
		return 0
	}

	score := 1

	neighbors := g.Neighbors(t)
	for _, n := range neighbors {
		viewingScore := 0
		for _, h := range n {
			viewingScore++
			if g.trees[t] <= h {
				break
			}

		}
		score *= viewingScore
	}

	return score
}

func (g TreeGrid) Neighbors(t TreeCoordinate) map[Direction][]int {
	neighbors := make(map[Direction][]int)

	for i := 0; i < g.size; i++ {
		if i < t.x {
			neighbors[W] = append([]int{g.trees[TreeCoordinate{i, t.y}]}, neighbors[W]...)
		} else if i > t.x {
			neighbors[E] = append(neighbors[E], g.trees[TreeCoordinate{i, t.y}])
		}

		if i < t.y {
			neighbors[N] = append([]int{g.trees[TreeCoordinate{t.x, i}]}, neighbors[N]...)

		} else if i > t.y {
			neighbors[S] = append(neighbors[S], g.trees[TreeCoordinate{t.x, i}])
		}
	}

	return neighbors
}
