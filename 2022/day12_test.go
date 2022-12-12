package main

import (
	"testing"
)

var inputTwelve = `Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi`

func TestDayTwelveOne(t *testing.T) {
	input := DayTwelveParse(inputTwelve)
	result := DayTwelveOne(input)

	if result != 31 {
		t.Errorf("Expected 31, got %d", result)
	}
}

func TestDayTwelveTwo(t *testing.T) {
	input := DayTwelveParse(inputTwelve)
	result := DayTwelveTwo(input)

	if result != 29 {
		t.Errorf("Expected 29, got %d", result)
	}
}
