package main

import (
	"fmt"
	"sort"
	"strconv"
	"strings"
)

func DayOne(skip bool) {
	if skip {
		return
	}

	input := parseInput(Read("day-1"))
	fmt.Println("Max calories: ", PartOne(input))
	fmt.Println("Max calories for top three elves:", PartTwo(input))
}

func PartOne(input []int) int {
	max := 0
	current := 0

	for _, value := range input {
		if value == -1 {
			if current > max {
				max = current
			}
			current = 0
		} else {
			current += value
		}
	}

	return max
}

func PartTwo(input []int) int {
	totals := []int{}
	current := 0

	for _, value := range input {
		if value == -1 {
			totals = append(totals, current)
			current = 0
		} else {
			current += value
		}
	}

	sort.Ints(totals)

	result := 0
	for _, total := range totals[len(totals)-3:] {
		result += total
	}

	return result
}

// read through inputs, replacing empty lines with -1
func parseInput(input string) []int {
	raw_input := strings.Split(input, "\n")
	ints := make([]int, len(raw_input))

	for idx, value := range raw_input {
		if value == "" {
			ints[idx] = -1
		} else if idx == len(raw_input)-1 {
			ints[idx+1] = -1
		} else {
			parsed, err := strconv.Atoi(value)
			if err != nil {
				panic(err)
			}
			ints[idx] = parsed

		}
	}

	return ints
}
