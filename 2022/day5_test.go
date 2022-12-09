package main

import (
	"reflect"
	"testing"
)

var inputFive = `    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2`

func TestDayFiveParse(t *testing.T) {

	stacks, instructions := DayFiveParse(inputFive)

	expected := [][]string{{"N", "Z"}, {"D", "C", "M"}, {"P"}}

	for idx := range expected {
		if !reflect.DeepEqual(stacks[idx], expected[idx]) {
			t.Errorf("Expected %v, got %v", expected, stacks)
		}
	}

	if !reflect.DeepEqual(instructions, []CrateInstruction{{1, 1, 0}, {3, 0, 2}, {2, 1, 0}, {1, 0, 1}}) {
		t.Errorf("Did not parse instructions correctly, got %v", instructions)
	}
}

func TestDayFiveOne(t *testing.T) {
	result := DayFiveOne(inputFive)

	if result != "CMZ" {
		t.Errorf("Expected \"CMZ\" got \"%s\"", result)
	}
}

func TestDayFiveTwo(t *testing.T) {
	result := DayFiveTwo(inputFive)

	if result != "MCD" {
		t.Errorf("Expected \"MCD\" got \"%s\"", result)
	}
}
