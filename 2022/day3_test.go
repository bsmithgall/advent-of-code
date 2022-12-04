package main

import "testing"

var inputThree = []string{
	"vJrwpWtwJgWrhcsFMMfFFhFp",
	"jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL",
	"PmmdzqPrVvPwwTWBwg",
	"wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn",
	"ttgJtRGJQctTZtZT",
	"CrZsJsPPZsGzwwsLwLmpwMDw",
}

func TestDayThreeOne(t *testing.T) {
	result := DayThreeOne(inputThree)

	if result != 157 {
		t.Errorf("Expected 157, got %d", result)
	}
}

func TestDayThreeTwo(t *testing.T) {
	result := DayThreeTwo(inputThree)

	if result != 70 {
		t.Errorf("Expected 70, got %d", result)
	}
}
