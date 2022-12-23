package main

import (
	"reflect"
	"strings"
	"testing"
)

var inputTwentyTwo = `        ...#
        .#..
        #...
        ....
...#.......#
........#...
..#....#....
..........#.
        ...#....
        .....#..
        .#......
        ......#.

10R5L5R10L4R5L5`

func TestDayTwentyTwoOne(t *testing.T) {
	parts := strings.Split(inputTwentyTwo, "\n\n")
	board, moves := ToMonkeyBoard(parts[0]), ToMonkeyMoves(parts[1])

	result := DayTwentyTwoOne(board, moves)

	if result != 6032 {
		t.Errorf("Expected 6032, got %d", result)
	}
}

func TestToMonkeyBoard(t *testing.T) {
	board := ToMonkeyBoard(strings.Split(inputTwentyTwo, "\n\n")[0])

	if !reflect.DeepEqual(board.position, Point{8, 0}) {
		t.Errorf("Expected {8,0}, got %v", board.position)

	}
}

func TestToMonkeyMoves(t *testing.T) {
	moves := ToMonkeyMoves(strings.Split(inputTwentyTwo, "\n\n")[1])

	if len(moves) != 7 {
		t.Errorf("Expected six moves, got %v", moves)
	}
}
