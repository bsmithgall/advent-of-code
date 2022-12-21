package main

import "fmt"

func DayTwenty(skip bool) {
	if skip {
		return
	}

	input := ToEncrypted(ReadInts("day-20"))
	fmt.Println(DayTwentyPartOne(input))
	fmt.Println(DayTwentyPartTwo(input))
}

func DayTwentyPartOne(encrypted Encrypted) int {
	return encrypted.Mix(encrypted.nums).DecryptedValue()
}

func DayTwentyPartTwo(encrypted Encrypted) int {
	decryptionKey := 811589153
	originalOrder := make([]PuzzleNum, len(encrypted.nums))

	for idx, val := range encrypted.nums {
		newNum := PuzzleNum{val.idx, val.val * decryptionKey}
		originalOrder[idx] = newNum
		encrypted.nums[idx] = newNum
	}

	for i := 0; i < 10; i++ {
		encrypted = encrypted.Mix(originalOrder)
	}

	return encrypted.DecryptedValue()
}

type PuzzleNum struct{ idx, val int }

// golang % on a negative number does not return a positive number.
func (p PuzzleNum) Mod(div int) int {
	return ((p.val % div) + div) % div
}

type Encrypted struct{ nums []PuzzleNum }

func (e Encrypted) Length() int          { return len(e.nums) }
func (e Encrypted) At(idx int) PuzzleNum { return e.nums[idx%e.Length()] }

func (e Encrypted) IndexOf(val PuzzleNum) int {
	for idx, num := range e.nums {
		if num == val {
			return idx
		}
	}
	return -1
}

func (e Encrypted) IndexOfVal(val int) int {
	for idx, num := range e.nums {
		if val == num.val {
			return idx
		}
	}

	return -1
}

func (e Encrypted) DecryptedValue() int {
	startIdx := e.IndexOfVal(0)
	return e.At(startIdx+1000).val + e.At(startIdx+2000).val + e.At(startIdx+3000).val
}

// return a copy of []PuzzleNum with the value at the passed idx removed. the
// length here will be (e.Length() - 1)
func (e Encrypted) SliceOut(idx int) Encrypted {
	result := make([]PuzzleNum, len(e.nums)-1)
	before, after := e.nums[:idx], e.nums[idx+1:]

	copy(result, before)
	copy(result[idx:], after)

	return Encrypted{result}
}

// return a copy of []PuzzleNum with the passed in num spliced it at the passed
// idx. the length will be (e.Length() + 1)
func (e Encrypted) SliceIn(num PuzzleNum, idx int) Encrypted {
	before, after := e.nums[:idx], e.nums[idx:]

	result := make([]PuzzleNum, len(e.nums)+1)
	copy(result, before)
	result[idx] = num
	copy(result[idx+1:], after)

	return Encrypted{result}
}

func (e Encrypted) Mix(mixOrder []PuzzleNum) Encrypted {
	mixed := Encrypted{make([]PuzzleNum, len(e.nums))}
	copy(mixed.nums, e.nums)
	for _, num := range mixOrder {
		curPosition := mixed.IndexOf(num)
		modBy := mixed.Length() - 1
		// https://stackoverflow.com/questions/43018206/modulo-of-negative-integers-in-go
		newPosition := (((curPosition + num.val) % modBy) + modBy) % modBy

		slicedOut := mixed.SliceOut(curPosition)
		mixed = slicedOut.SliceIn(num, newPosition)
	}

	return mixed
}

func ToEncrypted(input []int) Encrypted {
	nums := make([]PuzzleNum, len(input))
	for idx, val := range input {
		nums[idx] = PuzzleNum{idx, val}
	}
	return Encrypted{nums}
}
