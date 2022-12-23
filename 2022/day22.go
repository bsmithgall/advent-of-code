package main

import (
	"fmt"
	"math"
	"regexp"
	"strconv"
	"strings"
)

func DayTwentyTwo(skip bool) {
	if skip {
		return
	}

	parts := strings.Split(Read("day-22"), "\n\n")
	board, moves := ToMonkeyBoard(parts[0]), ToMonkeyMoves(parts[1])

	fmt.Println(DayTwentyTwoOne(board, moves))
	fmt.Println(DayTwentyTwoTwo(board, moves))
}

func DayTwentyTwoOne(board MonkeyBoard, moves []MonkeyMove) int {
	for _, move := range moves {
		board.position = board.Move(move.steps)
		board.facingIdx = board.Turn(move.turn)
	}

	return board.Score()
}

func DayTwentyTwoTwo(board MonkeyBoard, moves []MonkeyMove) int {
	for _, move := range moves {
		board.MoveAndFold(move.steps)
		board.facingIdx = board.Turn(move.turn)
	}

	return board.Score()

}

var right = Point{1, 0}
var down = Point{0, 1}
var left = Point{-1, 0}
var up = Point{0, -1}
var facings = []Point{right, down, left, up}

type MonkeyMove struct {
	steps int
	turn  string
}

type MonkeyBoard struct {
	width, height int
	grid          map[Point]string
	position      Point
	facingIdx     int
}

func (m MonkeyBoard) Score() int {
	return (1000*(m.position.y+1) + 4*(m.position.x+1) + m.facingIdx)
}

func (m MonkeyBoard) Direction() Point {
	return facings[m.facingIdx]
}

func (m MonkeyBoard) FacingIdx(from Point) int {
	for idx, f := range facings {
		if f.x == from.x && f.y == from.y {
			return idx
		}
	}

	return -1
}

func (m MonkeyBoard) Step(from Point) Point {
	to := from.Add(m.Direction())
	to.x, to.y = ModPos(to.x, m.width), ModPos(to.y, m.height)

	for {
		if _, ok := m.grid[to]; ok {
			break
		}
		to = to.Add(m.Direction())
		to.x, to.y = ModPos(to.x, m.width), ModPos(to.y, m.height)
	}

	if value := m.grid[to]; value == "." {
		return to
	}

	return from
}

func (m MonkeyBoard) Move(steps int) Point {
	to := m.position
	for i := 0; i < steps; i++ {
		to = m.Step(to)
	}
	return to
}

func (m MonkeyBoard) Turn(direction string) int {
	if direction == " " {
		return m.facingIdx
	} else if direction == "R" {
		return (m.facingIdx + 1) % 4
	}
	return ModPos((m.facingIdx - 1), 4)
}

func (m *MonkeyBoard) MoveAndFold(steps int) {
	for i := 0; i < steps; i++ {
		newPosition := m.position.Add(m.Direction())
		val, ok := m.grid[newPosition]
		if val == "#" {
			return
		}

		if ok {
			m.position = newPosition
		} else {
			folded, turned := m.FoldOverSeam()
			if foldedVal := m.grid[folded]; foldedVal != "#" {
				m.position = folded
				m.facingIdx = m.FacingIdx(turned)
			}
		}
	}
}

// this only works for my input...
func (m MonkeyBoard) FoldOverSeam() (Point, Point) {
	row := m.position.y
	col := m.position.x
	switch m.facingIdx {
	case 3: // up
		if row == 0 {
			if col >= 50 && col < 100 {
				return Point{0, col + 100}, right
			} else if col >= 100 && col < 150 {
				return Point{col - 100, 199}, up
			}
		} else if row == 100 {
			if col >= 0 && col < 50 {
				return Point{50, col + 50}, right
			}
		}
	case 1: // down
		if row == 199 {
			if col >= 0 && col < 50 {
				return Point{col + 100, 0}, down
			}
		} else if row == 149 {
			if col >= 50 && col < 100 {
				return Point{49, col + 100}, left
			}
		} else if row == 49 {
			if col >= 100 && col < 150 {
				return Point{99, col - 50}, left
			}
		}
	case 2: // left
		if col == 0 {
			if row >= 100 && row < 150 {
				return Point{50, 149 - row}, right
			} else if row >= 150 && row < 200 {
				return Point{row - 100, 0}, down
			}
		} else if col == 50 {
			if row >= 0 && row < 50 {
				return Point{0, 149 - row}, right
			} else if row >= 50 && row < 100 {
				return Point{row - 50, 100}, down
			}
		}
	case 0: // right
		if col == 49 {
			if row >= 150 && row < 200 {
				return Point{row - 100, 149}, up
			}
		} else if col == 99 {
			if row >= 50 && row < 100 {
				return Point{row + 50, 49}, up
			} else if row >= 100 && row < 150 {
				return Point{149, 149 - row}, left
			}
		} else if col == 149 {
			if row >= 0 && row < 50 {
				return Point{99, 149 - row}, left
			}
		}
	}

	fmt.Printf("col: %d, row: %d | %#v (%d)\n", col, row, m.Direction(), m.facingIdx)
	panic("oh no")
}

func ToMonkeyBoard(input string) MonkeyBoard {
	grid := make(map[Point]string)
	height, width, position := -1, -1, Point{math.MaxInt, math.MaxInt}

	for y, line := range strings.Split(input, "\n") {
		for x, char := range line {
			if char == ' ' {
				continue
			}
			grid[Point{x, y}] = string(char)
		}
	}

	for point := range grid {
		if point.x > width {
			width = point.x
		}

		if point.y > height {
			height = point.y
		}

		if point.y == 0 && point.x < position.x {
			position = point
		}
	}

	return MonkeyBoard{width + 1, height + 1, grid, position, 0}
}

func ToMonkeyMoves(input string) []MonkeyMove {
	moves := []MonkeyMove{}

	r := regexp.MustCompile(`([A-Z]|\d+)`)
	result := r.FindAllString(input, -1)

	for i := 1; i <= len(result); i += 2 {
		v, _ := strconv.Atoi(result[i-1])
		direction := " "
		if i < len(result) {
			direction = result[i]
		}
		moves = append(moves, MonkeyMove{v, direction})
	}

	return moves
}
