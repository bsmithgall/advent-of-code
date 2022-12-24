package main

import (
	"strings"
	"testing"
)

var inputTwentyFour = `#.######
#>>.<^<#
#.<..<<#
#>v.><>#
#<^v^^>#
######.#`

func TestDayTwentyFourOne(t *testing.T) {
	result := DayTwentyFourOne(strings.Split(inputTwentyFour, "\n"))

	if result != 18 {
		t.Errorf("Expected 18, got %d", result)
	}
}

func TestDayTwentyFourTwo(t *testing.T) {
	result := DayTwentyFourTwo(strings.Split(inputTwentyFour, "\n"))

	if result != 54 {
		t.Errorf("Expected 54, got %d", result)
	}
}
