package main

import "fmt"

func DaySix(skip bool) {
	if skip {
		return
	}

	input := Read("day-6")
	fmt.Printf("Start-of-packet marker detected at position %d\n", DaySixOne(input))
	fmt.Printf("Start-of-message marker detected at position %d\n", DaySixTwo(input))
}

func DaySixOne(input string) int {
	for i := 4; i < len(input); i++ {
		if isUnique(input[i-4 : i]) {
			return i
		}
	}
	return -1
}

func DaySixTwo(input string) int {
	for i := 14; i < len(input); i++ {
		if isUnique(input[i-14 : i]) {
			return i
		}
	}
	return -1
}

func isUnique(s string) bool {
	m := make(map[rune]bool)

	for _, r := range s {
		_, ok := m[r]
		if ok {
			return false
		}
		m[r] = true
	}

	return true
}
