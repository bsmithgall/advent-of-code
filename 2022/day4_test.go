package main

import "testing"

var inputFour = []string{
	"2-4,6-8",
	"2-3,4-5",
	"5-7,7-9",
	"2-8,3-7",
	"6-6,4-6",
	"2-6,4-8",
}

func TestDayFourOne(t *testing.T) {
	result := DayFourOne(inputFour)

	if result != 2 {
		t.Errorf("Expected 2, got %d", result)
	}
}

func TestDayFourTwo(t *testing.T) {
	result := DayFourTwo(inputFour)

	if result != 4 {
		t.Errorf("Expected 4, got %d", result)
	}
}
