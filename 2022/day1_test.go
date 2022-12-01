package main

import "testing"

func TestPartOne(t *testing.T) {
	input := []int{1000, 2000, 3000, -1, 4000, -1, 5000, 6000, -1, 7000, 8000, 9000, -1, 10000, -1}
	result := PartOne(input)

	if result != 24000 {
		t.Errorf("Expected 24000, Got %d", result)
	}
}

func TestPartTwo(t *testing.T) {
	input := []int{1000, 2000, 3000, -1, 4000, -1, 5000, 6000, -1, 7000, 8000, 9000, -1, 10000, -1}
	result := PartTwo(input)

	if result != 45000 {
		t.Errorf("Expected 45000, Got %d", result)
	}
}
