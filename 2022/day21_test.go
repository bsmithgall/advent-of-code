package main

import "testing"

var inputTwentyOne = []string{
	"root: pppw + sjmn",
	"dbpl: 5",
	"cczh: sllz + lgvd",
	"zczc: 2",
	"ptdq: humn - dvpt",
	"dvpt: 3",
	"lfqf: 4",
	"humn: 5",
	"ljgn: 2",
	"sjmn: drzm * dbpl",
	"sllz: 4",
	"pppw: cczh / lfqf",
	"lgvd: ljgn * ptdq",
	"drzm: hmdt - zczc",
	"hmdt: 32",
}

func TestTwentyOneOne(t *testing.T) {
	result := DayTwentyOneOne(inputTwentyOne)

	if result != 152 {
		t.Errorf("Expected 152, got %d", result)
	}
}

func TestTwentyOneTwo(t *testing.T) {
	result := DayTwentyOneTwo(inputTwentyOne)

	if result != 301 {
		t.Errorf("Expected 301, got %d", result)
	}
}
