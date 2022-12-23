package main

import "testing"

var inputTwentyThree = `....#..
..###.#
#...#.#
.#...##
#.###..
##.#.##
.#..#..`

func TestDayTwentyThreeOne(t *testing.T) {
	result := DayTwentyThreeOne(inputTwentyThree)

	if result != 110 {
		t.Errorf("Expected 110, got %d", result)
	}
}

func TestDayTwentyThreeTwo(t *testing.T) {
	result := DayTwentyThreeTwo(inputTwentyThree)

	if result != 20 {
		t.Errorf("Expected 20, got %d", result)
	}
}
