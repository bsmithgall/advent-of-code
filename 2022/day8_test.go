package main

import "testing"

var inputEight = [][]int{
	{3, 0, 3, 7, 3},
	{2, 5, 5, 1, 2},
	{6, 5, 3, 3, 2},
	{3, 3, 5, 4, 9},
	{3, 5, 3, 9, 0},
}

func TestDayEightOne(t *testing.T) {
	result := DayEightOne(inputEight)

	if result != 21 {
		t.Errorf("Expected 21, got %d", result)
	}
}

func TestDayEightTwo(t *testing.T) {
	result := DayEightTwo(inputEight)

	if result != 8 {
		t.Errorf("Expected 8, got %d", result)
	}
}
