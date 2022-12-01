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

// Convert a file of newline-separated integers into []int
func ReadInts(day string) []int {
	raw_data := strings.Split(Read(day), "\n")

	ints := make([]int, len(raw_data))

	for idx, value := range raw_data {
		parsed, err := strconv.Atoi(value)
		if err != nil {
			panic(err)
		}
		ints[idx] = parsed
	}

	return ints
}

// Convert a file of newline-separated rows of comma-separated integers into [][]int
func ReadMatrix(day string) [][]int {
	raw_data := strings.Split(Read(day), "\n")

	rows := make([][]int, len(raw_data))

	for idx, row_value := range raw_data {
		raw_row := strings.Split(row_value, ",")

		cols := make([]int, len(raw_row))

		for idy, col_value := range raw_row {
			parsed, err := strconv.Atoi(col_value)
			if err != nil {
				panic(err)
			}
			cols[idy] = parsed
		}

		rows[idx] = cols
	}

	return rows
}
