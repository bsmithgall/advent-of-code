package main

import (
	"os"
	"strconv"
	"strings"
)

func Read(day string) string {
	data, err := os.ReadFile("inputs/" + day + ".txt")
	if err != nil {
		panic(err)
	}
	return string(data)
}

func ReadLines(day string) []string {
	return strings.Split(Read(day), "\n")
}

// Convert a file of newline-separated integers into []int
func ReadInts(day string) []int {
	rawData := strings.Split(Read(day), "\n")

	ints := make([]int, len(rawData))

	for idx, value := range rawData {
		parsed, err := strconv.Atoi(value)
		if err != nil {
			panic(err)
		}
		ints[idx] = parsed
	}

	return ints
}

// Convert a file of newline-separated rows of comma-separated integers into [][]int
func ReadMatrix(day string, sep string) [][]int {
	rawData := strings.Split(Read(day), "\n")

	rows := make([][]int, len(rawData))

	for idx, rowValue := range rawData {
		rawRow := strings.Split(rowValue, sep)

		cols := make([]int, len(rawRow))

		for idy, colValue := range rawRow {
			parsed, err := strconv.Atoi(colValue)
			if err != nil {
				panic(err)
			}
			cols[idy] = parsed
		}

		rows[idx] = cols
	}

	return rows
}

func Abs(x int) int {
	if x < 0 {
		return -x
	}
	return x
}
