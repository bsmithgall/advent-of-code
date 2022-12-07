package main

import "testing"

func TestDaySixOne(t *testing.T) {
	type test struct {
		input    string
		expected int
	}

	tests := []test{
		{"mjqjpqmgbljsphdztnvjfqwrcgsmlb", 7},
		{"bvwbjplbgvbhsrlpgdmjqwftvncz", 5},
		{"nppdvjthqldpwncqszvftbrmjlhg", 6},
		{"nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 10},
		{"zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 11},
	}

	for _, test := range tests {
		result := DaySixOne(test.input)
		if result != test.expected {
			t.Errorf("Expeted %d, got %d", test.expected, result)
		}
	}
}

func TestDaySixTwo(t *testing.T) {
	type test struct {
		input    string
		expected int
	}

	tests := []test{
		{"mjqjpqmgbljsphdztnvjfqwrcgsmlb", 19},
		{"bvwbjplbgvbhsrlpgdmjqwftvncz", 23},
		{"nppdvjthqldpwncqszvftbrmjlhg", 23},
		{"nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 29},
		{"zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 26},
	}

	for _, test := range tests {
		result := DaySixTwo(test.input)
		if result != test.expected {
			t.Errorf("Expeted %d, got %d", test.expected, result)
		}
	}
}
