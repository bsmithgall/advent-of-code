package main

import (
	"fmt"
	"sort"
	"strconv"
	"strings"
)

func DayEleven(skip bool) {
	if skip {
		return
	}

	input := strings.Split(Read("day-11"), "\n\n")

	fmt.Printf("Monkey business level: %d\n", DayElevenOne(input))
	fmt.Printf("Monkey business level: %d\n", DayElevenTwo(input))

}

func DayElevenOne(input []string) int {
	monkeys := make([]Monkey, len(input))
	for i, m := range input {
		monkeys[i] = MonkeyParse(m)
	}

	for round := 0; round < 20; round++ {
		for i, monkey := range monkeys {
			updated, toThrow := monkey.takeTurn(func(i int) int { return i / 3 })
			monkeys[i] = updated
			for m, items := range toThrow {
				monkeys[m] = monkeys[m].catchItems(items)
			}
		}
	}

	touches := make([]int, len(monkeys))
	for _, m := range monkeys {
		touches = append(touches, m.touches)
	}
	sort.Ints(touches)

	return touches[len(touches)-1] * touches[len(touches)-2]
}

func DayElevenTwo(input []string) int {
	monkeys := make([]Monkey, len(input))
	modBy := 1

	for i, m := range input {
		monkeys[i] = MonkeyParse(m)
		modBy *= monkeys[i].modBy
	}

	for round := 0; round < 10000; round++ {
		for idx, monkey := range monkeys {
			updated, toThrow := monkey.takeTurn(func(i int) int { return i % modBy })
			monkeys[idx] = updated
			for m, items := range toThrow {
				monkeys[m] = monkeys[m].catchItems(items)
			}
		}
	}

	touches := make([]int, len(monkeys))
	for _, m := range monkeys {
		touches = append(touches, m.touches)
	}
	sort.Ints(touches)

	return touches[len(touches)-1] * touches[len(touches)-2]
}

func MonkeyParse(input string) Monkey {
	lines := strings.Split(input, "\n")

	id, _ := strconv.Atoi(strings.Split(lines[0], " ")[1][0:1])

	items := []int{}
	for _, item := range strings.Split(strings.Split(lines[1], ": ")[1], ",") {
		val, _ := strconv.Atoi(strings.TrimSpace(item))
		items = append(items, val)
	}

	operationParts := strings.Split(lines[2], " ")
	operation := func(i int) int {
		operand, err := strconv.Atoi(strings.TrimSpace(operationParts[len(operationParts)-1]))
		if err != nil {
			operand = i
		}
		switch strings.TrimSpace(operationParts[len(operationParts)-2]) {
		case "+":
			i = i + operand
		case "*":
			i = i * operand
		}
		return i
	}

	modBy, _ := strconv.Atoi(strings.Split(lines[3], " ")[len(strings.Split(lines[3], " "))-1])
	whenTrue, _ := strconv.Atoi(strings.Split(lines[4], " ")[len(strings.Split(lines[4], " "))-1])
	whenFalse, _ := strconv.Atoi(strings.Split(lines[5], " ")[len(strings.Split(lines[5], " "))-1])

	test := func(i int) int {
		if i%modBy == 0 {
			return whenTrue
		}
		return whenFalse
	}

	return Monkey{id, items, operation, test, modBy, 0}
}

type Monkey struct {
	id        int
	items     []int
	operation func(int) int
	test      func(int) int
	modBy     int
	touches   int
}

func (m Monkey) takeTurn(manageLevel func(i int) int) (Monkey, map[int][]int) {
	toThrow := make(map[int][]int)
	touches := m.touches

	for _, item := range m.items {
		touches += 1
		worryLevel := manageLevel(m.operation(item))
		throwTo := m.test(worryLevel)

		items, ok := toThrow[throwTo]
		if ok {
			toThrow[throwTo] = append(items, worryLevel)
		} else {
			toThrow[throwTo] = []int{worryLevel}
		}
	}

	return Monkey{m.id, []int{}, m.operation, m.test, m.modBy, touches}, toThrow
}

func (m Monkey) catchItems(items []int) Monkey {
	m.items = append(m.items, items...)
	return m
}
