package main

import (
	"reflect"
	"testing"
)

var inputFourteen = []string{
	"498,4 -> 498,6 -> 496,6",
	"503,4 -> 502,4 -> 502,9 -> 494,9",
}

func TestDayFourteenOne(t *testing.T) {
	result := DayFourteenOne(inputFourteen)

	if result != 24 {
		t.Errorf("Expected 24, got %d", result)
	}
}

func TestDayFourteenTwo(t *testing.T) {
	result := DayFourteenTwo(inputFourteen)

	if result != 93 {
		t.Errorf("Expected 93, got %d", result)
	}
}

func TestFillTo(t *testing.T) {
	type test struct {
		start, end RockCoord
		expected   []RockCoord
	}

	tests := []test{
		{RockCoord{498, 4}, RockCoord{498, 6}, []RockCoord{{498, 4}, {498, 5}, {498, 6}}},
		{RockCoord{498, 6}, RockCoord{496, 6}, []RockCoord{{498, 6}, {497, 6}, {496, 6}}},
	}

	for _, test := range tests {
		result := test.start.FillTo(test.end)

		if !reflect.DeepEqual(result, test.expected) {
			t.Errorf("Expected %v, got %v", test.expected, result)
		}
	}

}
