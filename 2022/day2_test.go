package main

import "testing"

func TestDayTwoOne(t *testing.T) {
	input := [][2]string{{"A", "Y"}, {"B", "X"}, {"C", "Z"}}
	result := DayTwoOne(input)

	if result != 15 {
		t.Errorf("Expected 15, got %d", result)
	}
}

func TestDayTwoTwo(t *testing.T) {
	input := [][2]string{{"A", "Y"}, {"B", "X"}, {"C", "Z"}}
	result := DayTwoTwo(input)

	if result != 12 {
		t.Errorf("Expected 12, got %d", result)
	}
}
