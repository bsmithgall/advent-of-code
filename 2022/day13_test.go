package main

import "testing"

var inputThirteen = [][2]string{
	{"[1,1,3,1,1]", "[1,1,5,1,1]"},
	{"[[1],[2,3,4]]", "[[1],4]"},
	{"[9]", "[[8,7,6]]"},
	{"[[4,4],4,4]", "[[4,4],4,4,4]"},
	{"[7,7,7,7]", "[7,7,7]"},
	{"[]", "[3]"},
	{"[[[]]]", "[[]]"},
	{"[1,[2,[3,[4,[5,6,7]]]],8,9]", "[1,[2,[3,[4,[5,6,0]]]],8,9]"},
}

var expected = []int{-1, -1, 1, -1, 1, -1, 1, 1}

func TestCompare(t *testing.T) {
	for idx, pairs := range inputThirteen {
		left, right := DayThirteenParse(pairs[0]), DayThirteenParse(pairs[1])

		actual := left.Compare(right)
		if actual != expected[idx] {
			t.Errorf("Pairs [%v|%v] gave incorrect value %d, expected %d", left, right, actual, expected[idx])
		}
	}
}

func TestDayThirteenOne(t *testing.T) {
	result := DayThirteenOne(inputThirteen)

	if result != 13 {
		t.Errorf("Expected 13, got %d", result)
	}
}

func TestDayThirteenTwo(t *testing.T) {
	allLines := []string{}

	for _, pairs := range inputThirteen {
		allLines = append(allLines, pairs[0])
		allLines = append(allLines, pairs[1])
	}

	result := DayThirteenTwo(allLines)
	if result != 140 {
		t.Errorf("Expected 140, got %d", result)
	}
}
