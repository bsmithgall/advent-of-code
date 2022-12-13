package main

import (
	"encoding/json"
	"fmt"
	"reflect"
	"sort"
	"strings"
)

func DayThirteen(skip bool) {
	if skip {
		return
	}

	input := Read("day-13")
	parts := strings.Split(input, "\n\n")
	pairs := make([][2]string, len(parts))
	lines := []string{}
	for idx, part := range parts {
		pairStr := strings.Split(part, "\n")
		pairs[idx] = [2]string{pairStr[0], pairStr[1]}
		lines = append(lines, pairStr[0], pairStr[1])
	}

	fmt.Printf("Ordered pair sum: %d\n", DayThirteenOne(pairs))
	fmt.Printf("Decoder key: %d\n", DayThirteenTwo(lines))
}

func DayThirteenOne(pairs [][2]string) int {
	total := 0
	for idx, pairs := range pairs {
		left, right := DayThirteenParse(pairs[0]), DayThirteenParse(pairs[1])

		if left.Compare(right) == -1 {
			total += idx + 1
		}
	}

	return total
}

func DayThirteenTwo(lines []string) int {
	total := 1
	twoDecoder := "[[2]]"
	sixDecoder := "[[6]]"
	withDecoders := append(lines, twoDecoder, sixDecoder)

	sort.Slice(withDecoders, func(i, j int) bool {
		return DayThirteenParse(withDecoders[i]).Compare(DayThirteenParse(withDecoders[j])) < 0
	})

	for idx, line := range withDecoders {
		if line == twoDecoder || line == sixDecoder {
			total *= (idx + 1)
		}
	}

	return total
}

type DistressPacket struct{ d any }

// there has to be a better way...
func (p DistressPacket) IsSlice() bool                { return strings.HasPrefix(reflect.TypeOf(p.d).String(), "[]") }
func (p DistressPacket) Number() float64              { return p.d.(float64) }
func (p DistressPacket) Slice() DistressPacket        { return DistressPacket{[]any{p.d}} }
func (p DistressPacket) ValAt(idx int) DistressPacket { return DistressPacket{p.d.([]any)[idx]} }

func (p DistressPacket) Length() int {
	if p.IsSlice() {
		return len(p.d.([]any))
	}

	return -1
}

func (l DistressPacket) Compare(r DistressPacket) int {
	lIsSlice, rIsSlice := l.IsSlice(), r.IsSlice()
	// both numbers
	if !lIsSlice && !rIsSlice {
		lVal := l.Number()
		rVal := r.Number()
		if lVal < rVal {
			return -1
		} else if lVal > rVal {
			return 1
		} else {
			return 0
		}
	}

	// both slices
	if lIsSlice && rIsSlice {
		lLen, rLen := l.Length(), r.Length()

		toCompare := 0
		if lLen < rLen {
			toCompare = lLen
		} else {
			toCompare = rLen
		}

		// compare inner vals through to the smaller length
		for i := 0; i < toCompare; i++ {
			res := l.ValAt(i).Compare(r.ValAt(i))
			if res != 0 {
				return res
			}
		}

		// if we run out of comparisons, use slice length
		if lLen < rLen {
			return -1
		} else if lLen > rLen {
			return 1
		}

		return 0

	}

	if lIsSlice && !rIsSlice {
		return l.Compare(r.Slice())
	}

	if !lIsSlice && rIsSlice {
		return l.Slice().Compare(r)
	}

	panic("Oh no!")
}

func DayThirteenParse(input string) DistressPacket {
	var data []any
	err := json.Unmarshal([]byte(input), &data)
	if err != nil {
		panic(err)
	}

	return DistressPacket{data}
}
