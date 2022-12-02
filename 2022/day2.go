package main

import (
	"fmt"
	"strings"
)

func DayTwo(skip bool) {
	if skip {
		return
	}

	raw_input := strings.Split(Read("day-2"), "\n")
	input := make([][2]string, len(raw_input))

	for idx, value := range raw_input {
		var arr [2]string
		copy(arr[:], strings.Split(value, " "))
		input[idx] = arr
	}

	fmt.Println("Score based on assumed R/P/S: ", DayTwoOne(input))
	fmt.Println("Score based on second value as outcome: ", DayTwoTwo(input))
}

func DayTwoOne(input [][2]string) int {
	result := 0
	for _, value := range input {
		opp, me := toShape(value[0]), toShape(value[1])
		result += me.vs(opp) + me.val()
	}
	return result
}

func DayTwoTwo(input [][2]string) int {
	result := 0
	for _, value := range input {
		opp := toShape(value[0])
		me := shapeFromResult(opp, value[1])
		result += me.vs(opp) + me.val()
	}
	return result
}

type Shape int

const (
	Invalid Shape = iota
	Rock
	Paper
	Scissors
)

func (s Shape) val() int {
	switch s {
	case Rock:
		return 1
	case Paper:
		return 2
	case Scissors:
		return 3
	}
	return -1
}

func (s Shape) vs(other Shape) int {
	switch s {
	case Rock:
		switch other {
		case Rock:
			return 3
		case Scissors:
			return 6
		case Paper:
			return 0
		}
	case Scissors:
		switch other {
		case Rock:
			return 0
		case Paper:
			return 6
		case Scissors:
			return 3
		}
	case Paper:
		switch other {
		case Rock:
			return 6
		case Paper:
			return 3
		case Scissors:
			return 0
		}
	}
	return -1
}

func toShape(value string) Shape {
	switch value {
	case "A", "X":
		return Rock
	case "B", "Y":
		return Paper
	case "C", "Z":
		return Scissors
	default:
		return Invalid
	}
}

func shapeFromResult(opp Shape, result string) Shape {
	switch result {
	case "X": // lose
		switch opp {
		case Rock:
			return Scissors
		case Paper:
			return Rock
		case Scissors:
			return Paper
		}
	case "Y": // tie
		return opp
	case "Z": // win
		switch opp {
		case Rock:
			return Paper
		case Paper:
			return Scissors
		case Scissors:
			return Rock
		}
	default:
		return Invalid
	}
	return Invalid
}
