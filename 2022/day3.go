package main

import (
	"fmt"
	"strings"
)

const Alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

func DayThree(skip bool) {
	if skip {
		return
	}

	input := ReadLines("day-3")

	fmt.Println("Rucksack priority sum: ", DayThreeOne(input))
	fmt.Println("Badge priority sum: ", DayThreeTwo(input))
}

func DayThreeOne(input []string) int {
	result := 0

	for _, line := range input {
		result += findMatchingPart(line)
	}

	return result
}

func DayThreeTwo(input []string) int {
	result := 0
	for i := 3; i <= len(input); i += 3 {
		result += findCommonLetter(input[i-3 : i])
	}
	return result
}

func findMatchingPart(contents string) int {
	first, second := contents[len(contents)/2:], contents[:len(contents)/2]

	for _, value := range first {
		if strings.ContainsAny(second, string(value)) {
			return strings.Index(Alphabet, string(value)) + 1
		}
	}

	panic("Uh oh")
}

func findCommonLetter(contents []string) int {
	commons := make(map[string][2]int)

	for idx, value := range contents {
		for _, v := range value {
			value, present := commons[string(v)]
			if !present {
				commons[string(v)] = [2]int{1, idx}
			} else {
				if value[1] != idx {
					commons[string(v)] = [2]int{value[0] + 1, idx}
				}
			}
		}
	}

	for k, v := range commons {
		if v[0] == 3 {
			return strings.Index(Alphabet, k) + 1
		}
	}

	panic("Oh no")
}
