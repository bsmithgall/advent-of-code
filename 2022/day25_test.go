package main

import "testing"

func TestSnafuConversions(t *testing.T) {

	tests := []struct {
		snafu   string
		decimal int
	}{
		{"1=-0-2", 1747}, //  3125 + (-2 * 625) + (-1 * 125) + (0 * 25) + (-1 * 5) + (2 * 1)
		{"12111", 906},   // (1 * 625) + (2 * 125) + (1 * 25) + (1 * 5) + (1 * 1)
		{"2=0=", 198},    // (2 * 125) + (-2 * 25) + (0 * 5) + (-2 * 1)
		{"21", 11},
		{"2=01", 201}, // (2 * 125) + (-2 * 25) + (0 * 5) + (1 * 1)
		{"111", 31},
		{"20012", 1257},
		{"112", 32},
		{"1=-1=", 353},
		{"1-12", 107},
		{"12", 7},
		{"1=", 3},
		{"122", 37},
	}

	for _, test := range tests {
		// if result := FromSnafu(test.snafu); result != test.decimal {
		// 	t.Errorf("Expected %d, got %d (from %s)", test.decimal, result, test.snafu)
		// }

		if result := ToSnafu(test.decimal); result != test.snafu {
			t.Errorf("Expected %s, got %s (from %d)", test.snafu, result, test.decimal)
		}
	}
}
