package main

import "testing"

var inputEighteen = [][]int{
	{2, 2, 2},
	{1, 2, 2},
	{3, 2, 2},
	{2, 1, 2},
	{2, 3, 2},
	{2, 2, 1},
	{2, 2, 3},
	{2, 2, 4},
	{2, 2, 6},
	{1, 2, 5},
	{3, 2, 5},
	{2, 1, 5},
	{2, 3, 5},
}

func TestDayEighteenOne(t *testing.T) {
	result := DayEighteenOne(inputEighteen)

	if result != 64 {
		t.Errorf("Expected 64, got %d", result)
	}
}

func TestDayEighteenTwo(t *testing.T) {
	result := DayEighteenTwo(inputEighteen)

	if result != 58 {
		t.Errorf("Expected 58, got %d", result)
	}
}
