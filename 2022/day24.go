package main

import "fmt"

func DayTwentyFour(skip bool) {
	if skip {
		return
	}

	input := ReadLines("day-24")

	fmt.Println("Steps to exit: ", DayTwentyFourOne(input))
	fmt.Println("Steps to there and back and there again: ", DayTwentyFourTwo(input))
}

func DayTwentyFourOne(input []string) int {
	b := ToBlizzardMap(input)
	ticks := 0

	for !b.Reachable(b.width-2, b.height-1) {
		b.Tick()
		ticks += 1
	}

	return ticks
}

func DayTwentyFourTwo(input []string) int {
	b := ToBlizzardMap(input)
	ticks := 0
	for !b.Reachable(b.width-2, b.height-1) {
		b.Tick()
		ticks += 1
	}
	b.grid = b.InitEmptyGrid(b.width-2, b.height-1)
	for !b.Reachable(1, 0) {
		b.TickRev()
		ticks += 1
	}
	b.grid = b.InitEmptyGrid(1, 0)
	for !b.Reachable(b.width-2, b.height-1) {
		b.Tick()
		ticks += 1
	}
	return ticks
}

type CellType = int

const (
	Empty CellType = iota
	Blizz
	Reachable
)

type BlizzardCell struct {
	t CellType
}

func (c BlizzardCell) String() string {
	switch c.t {
	case Blizz:
		return "x"
	case Reachable:
		return "E"
	default:
		return "."
	}
}

type Blizzard struct {
	x, y      int
	direction string
}

func (b *Blizzard) Tick(width, height int) {
	x, y := b.x, b.y
	switch b.direction {
	case "^":
		y = b.y - 1
		if y == 0 {
			y = height - 2
		}
	case "v":
		y = b.y + 1
		if y == height-1 {
			y = 1
		}
		b.y = y
	case "<":
		x = b.x - 1
		if x == 0 {
			x = width - 2
		}
	case ">":
		x = b.x + 1
		if x == width-1 {
			x = 1
		}
	}
	b.x, b.y = x, y
}

type BlizzardMap struct {
	blizzards     []Blizzard
	grid          [][]BlizzardCell
	height, width int
}

func (m BlizzardMap) Reachable(x, y int) bool { return m.grid[y][x].t == Reachable }
func (m BlizzardMap) Empty(x, y int) bool     { return m.grid[y][x].t == Empty }

func (m BlizzardMap) AnyReachable(x, y int) bool {
	return m.Reachable(x, y) || m.Reachable(x, y-1) || m.Reachable(x, y+1) || m.Reachable(x-1, y) || m.Reachable(x+1, y)
}

func (m BlizzardMap) InitEmptyGrid(x, y int) [][]BlizzardCell {
	grid := make([][]BlizzardCell, m.height)

	for y := 0; y < m.height; y++ {
		grid[y] = make([]BlizzardCell, m.width)
	}

	grid[y][x] = BlizzardCell{Reachable}

	return grid
}

func (m *BlizzardMap) Tick() {
	nextGrid := m.InitEmptyGrid(1, 0)

	for idx, blizzard := range m.blizzards {
		blizzard.Tick(m.width, m.height)
		m.blizzards[idx] = blizzard
		nextGrid[blizzard.y][blizzard.x] = BlizzardCell{Blizz}
	}

	for y := 1; y < m.height-1; y++ {
		for x := 1; x < m.width-1; x++ {
			// we _will_ be empty and are _currently_ reachable
			if nextGrid[y][x].t == Empty && m.AnyReachable(x, y) {
				nextGrid[y][x] = BlizzardCell{Reachable}
			}
		}
	}

	// exit is reachable if the step directly above it is reachable
	if m.Reachable(m.width-2, m.height-2) {
		nextGrid[m.height-1][m.width-2] = BlizzardCell{Reachable}
	}

	m.grid = nextGrid
}

func (m *BlizzardMap) TickRev() {
	nextGrid := m.InitEmptyGrid(m.width-2, m.height-1)

	for idx, blizzard := range m.blizzards {
		blizzard.Tick(m.width, m.height)
		m.blizzards[idx] = blizzard
		nextGrid[blizzard.y][blizzard.x] = BlizzardCell{Blizz}
	}

	for y := 1; y < m.height-1; y++ {
		for x := 1; x < m.width-1; x++ {
			// we _will_ be empty and are _currently_ reachable
			if nextGrid[y][x].t == Empty && m.AnyReachable(x, y) {
				nextGrid[y][x] = BlizzardCell{Reachable}
			}
		}
	}

	// exit is reachable if the step directly above it is reachable
	if m.Reachable(1, 1) {
		nextGrid[0][1] = BlizzardCell{Reachable}
	}

	m.grid = nextGrid

}

func (m BlizzardMap) CanExit() bool {
	return m.Reachable(m.width-2, m.height-1)
}

func (m BlizzardMap) String() string {
	out := ""

	for y := 1; y < m.height-1; y++ {
		for x := 1; x < m.width-1; x++ {
			out += m.grid[y][x].String()
		}
		out += "\n"
	}

	return out
}

func ToBlizzardMap(input []string) BlizzardMap {
	blizzards := []Blizzard{}
	grid := make([][]BlizzardCell, len(input))

	for y, line := range input {
		grid[y] = make([]BlizzardCell, len(line))
		for x, char := range line {
			if char == '^' || char == 'v' || char == '<' || char == '>' {
				blizzards = append(blizzards, Blizzard{x, y, string(char)})
			}
		}
	}

	// initialize starting position
	grid[1][0] = BlizzardCell{Reachable}

	return BlizzardMap{blizzards: blizzards, grid: grid, height: len(input), width: len(input[0])}
}
