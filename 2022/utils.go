package main

import (
	"math"
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

// like java's signum()
func Signum(x int) int {
	if x == 0 {
		return 0
	}
	if math.Signbit(float64(x)) {
		return -1
	}
	return 1
}

// like functools.combinations
// taken from: https://www.sobyte.net/post/2022-01/go-slice/
func Combinations(iterable []string, r int) (rt [][]string) {
	pool := iterable
	n := len(pool)

	if r > n {
		return
	}

	indices := make([]int, r)
	for i := range indices {
		indices[i] = i
	}

	result := make([]string, r)
	for i, el := range indices {
		result[i] = pool[el]
	}
	s2 := make([]string, r)
	copy(s2, result)
	rt = append(rt, s2)

	for {
		i := r - 1
		for ; i >= 0 && indices[i] == i+n-r; i -= 1 {
		}

		if i < 0 {
			return
		}

		indices[i] += 1
		for j := i + 1; j < r; j += 1 {
			indices[j] = indices[j-1] + 1
		}

		for ; i < len(indices); i += 1 {
			result[i] = pool[indices[i]]
		}
		s2 = make([]string, r)
		copy(s2, result)
		rt = append(rt, s2)
	}

}

func Max(x int, y int) int {
	if x > y {
		return x
	}
	return y
}

// https://stackoverflow.com/questions/43018206/modulo-of-negative-integers-in-go
func ModPos(i, modBy int) int {
	return ((i % modBy) + modBy) % modBy
}

// should have done this a long time ago...
type Point struct{ x, y int }

func (p Point) Add(o Point) Point {
	return Point{p.x + o.x, p.y + o.y}
}
