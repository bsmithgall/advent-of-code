package main

import "testing"

var inputNine = []RopeInstruction{
	{"R", 4},
	{"U", 4},
	{"L", 3},
	{"D", 1},
	{"R", 4},
	{"D", 1},
	{"L", 5},
	{"R", 2},
}

func TestDayNineOne(t *testing.T) {
	result := DayNineOne(inputNine)

	if result != 13 {
		t.Errorf("Expected 13, got %d", result)
	}
}

func TestDayNineTwo(t *testing.T) {
	result := DayNineTwo([]RopeInstruction{
		{"R", 5},
		{"U", 8},
		{"L", 8},
		{"D", 3},
		{"R", 17},
		{"D", 10},
		{"L", 25},
		{"U", 20},
	})

	// result := DayNineTwo([]RopeInstruction{
	// 	{"R", 4},
	// 	{"U", 4},
	// 	{"L", 3},
	// 	{"D", 1},
	// })

	if result != 36 {
		t.Errorf("Expected 36, got %d", result)
	}
}

func TestMove(t *testing.T) {
	type test struct {
		instruction RopeInstruction
		expected    Rope
	}

	tests := []test{
		{RopeInstruction{"R", 4}, Rope{RopePosition{4, 0}, RopePosition{3, 0}}},
		{RopeInstruction{"U", 4}, Rope{RopePosition{4, 4}, RopePosition{4, 3}}},
		{RopeInstruction{"L", 3}, Rope{RopePosition{1, 4}, RopePosition{2, 4}}},
		{RopeInstruction{"D", 1}, Rope{RopePosition{1, 3}, RopePosition{2, 4}}},
	}

	rope := Rope{RopePosition{0, 0}, RopePosition{0, 0}}

	for _, test := range tests {
		rope, _ = rope.Move(test.instruction)
		if rope != test.expected {
			t.Errorf("Expected %v, got %v", test.expected, rope)
		}
	}
}
