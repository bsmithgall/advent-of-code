package main

import "testing"

var inputSeventeen = ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"

func TestDaySeventeenOne(t *testing.T) {
	result := DaySeventeenOne(inputSeventeen, 2022)

	if result != 3068 {
		t.Errorf("Expected 3068, got %d", result)
	}
}

func TestDaySeventeenTwo(t *testing.T) {
	result := DaySeventeenTwo(inputSeventeen, 1000000000000)

	if result != 1514285714288 {
		t.Errorf("Expected 1514285714288, got %d (diff %d)", result, 1514285714288-result)
	}

}
