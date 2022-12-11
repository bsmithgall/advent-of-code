package main

import (
	"reflect"
	"strings"
	"testing"
)

var monkeyInput = `Monkey 0:
Starting items: 79, 98
Operation: new = old * 19
Test: divisible by 23
	If true: throw to monkey 2
	If false: throw to monkey 3

Monkey 1:
Starting items: 54, 65, 75, 74
Operation: new = old + 6
Test: divisible by 19
	If true: throw to monkey 2
	If false: throw to monkey 0

Monkey 2:
Starting items: 79, 60, 97
Operation: new = old * old
Test: divisible by 13
	If true: throw to monkey 1
	If false: throw to monkey 3

Monkey 3:
Starting items: 74
Operation: new = old + 3
Test: divisible by 17
	If true: throw to monkey 0
	If false: throw to monkey 1
`

func TestDayElevenOne(t *testing.T) {
	monkeyStrs := strings.Split(monkeyInput, "\n\n")

	result := DayElevenOne(monkeyStrs)
	if result != 10605 {
		t.Errorf("Expectd 10605, got %d", result)
	}
}

func TestDayElevenTwo(t *testing.T) {
	monkeyStrs := strings.Split(monkeyInput, "\n\n")

	result := DayElevenTwo(monkeyStrs)
	if result != 2713310158 {
		t.Errorf("Expectd 2713310158, got %d", result)
	}
}

func TestMonkeyParse(t *testing.T) {
	inputStr := `Monkey 0:
  Starting items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3`

	result := MonkeyParse(inputStr)

	if result.id != 0 {
		t.Errorf("Expected id 0, got %d", result.id)
	}

	if !reflect.DeepEqual(result.items, []int{79, 98}) {
		t.Errorf("Expected {79,98}, got %v", result.items)
	}

	if result.operation(1) != 19 {
		t.Errorf("Incorrect monkey operation")
	}

	if result.test(23) != 2 {
		t.Errorf("Incorrect monkey test for true case")
	}

	if result.test(24) != 3 {
		t.Errorf("Incorrect monkey test for false case")
	}
}

func TestMonkeyThrow(t *testing.T) {
	inputStr := `Monkey 0:
  Starting items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3`

	monkey := MonkeyParse(inputStr)
	updated, result := monkey.takeTurn(func(i int) int { return i / 3 })

	if len(result[2]) > 0 {
		t.Errorf("Incorrect result for monkey 2: %v", result[2])
	}

	if !reflect.DeepEqual(result[3], []int{500, 620}) {
		t.Errorf("Incorrect result for monkey 3")
	}

	if len(updated.items) > 0 {
		t.Errorf("Did not properly empty items!")
	}

	if updated.touches != 2 {
		t.Errorf("Did not properly accumulate item touches!")
	}

}
