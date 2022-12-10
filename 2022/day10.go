package main

import (
	"fmt"
	"strconv"
	"strings"
)

func DayTen(skip bool) {
	if skip {
		return
	}

	input := ReadLines("day-10")

	fmt.Printf("Total signal strength: %d\n", DayTenOne(input))
	fmt.Printf("%s\n", DayTenTwo(input))
}

func DayTenOne(input []string) int {
	register := 1
	cycle := 0
	signalStrength := 0

	for _, instruction := range input {
		parts := strings.Split(instruction, " ")
		cycle += 1
		if cycle%40 == 20 {
			signalStrength += cycle * register
		}
		if parts[0] == "noop" {
			continue
		} else {
			cycle += 1
			if cycle%40 == 20 {
				signalStrength += cycle * register
			}
			val, _ := strconv.Atoi(parts[1])
			register += val
		}
	}

	return signalStrength
}

func DayTenTwo(input []string) string {
	register := 1
	cycle := 0
	output := ""

	for _, instruction := range input {
		parts := strings.Split(instruction, " ")
		if cycle%40 == 0 {
			output += "\n"
		}
		cycle += 1
		output += DrawPixel(cycle-1, register)
		if parts[0] == "noop" {
			continue
		} else {
			if cycle%40 == 0 {
				output += "\n"
			}
			cycle += 1
			output += DrawPixel(cycle-1, register)
			val, _ := strconv.Atoi(parts[1])
			register += val
		}

	}
	return output
}

func DrawPixel(position int, register int) string {
	if position%40 == register-1 || position%40 == register || position%40 == register+1 {
		return "#"
	} else {
		return "."
	}
}
