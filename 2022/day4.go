package main

import (
	"fmt"
	"strconv"
	"strings"
)

func DayFour(skip bool) {
	if skip {
		return
	}

	input := ReadLines("day-4")
	fmt.Printf("Overlapping section ids: %d\n", DayFourOne(input))
	fmt.Printf("Partialy overlapping section ids: %d\n", DayFourTwo(input))
}

func DayFourOne(input []string) int {
	result := 0
	for _, sectionGroup := range input {
		sections := strings.Split(sectionGroup, ",")
		sectionOne := makeSection(sections[0])
		sectionTwo := makeSection(sections[1])
		if sectionOne.contains(sectionTwo) || sectionTwo.contains(sectionOne) {
			result += 1
		}
	}

	return result
}

func DayFourTwo(input []string) int {
	result := 0
	for _, sectionGroup := range input {
		sections := strings.Split(sectionGroup, ",")
		sectionOne := makeSection(sections[0])
		sectionTwo := makeSection(sections[1])
		if sectionOne.contains(sectionTwo) || sectionTwo.contains(sectionOne) || !sectionOne.disjoint(sectionTwo) {
			result += 1
		}
	}

	return result
}

type Section struct {
	start int
	end   int
}

func makeSection(section string) Section {
	parts := strings.Split(section, "-")
	leftStr, rightStr := parts[0], parts[1]

	left, _ := strconv.Atoi(leftStr)
	right, _ := strconv.Atoi(rightStr)

	return Section{left, right}
}

func (s Section) contains(other Section) bool {
	return s.start <= other.start && s.end >= other.end
}

func (s Section) disjoint(other Section) bool {
	result := s.start > other.end || s.end < other.start
	return result
}
