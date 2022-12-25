package main

import (
	"fmt"
	"math"
	"strconv"
)

func DayTwentyFive(skip bool) {
	if skip {
		return
	}

	sum := 0

	for _, line := range ReadLines("day-25") {
		sum += FromSnafu(line)
	}

	fmt.Println(ToSnafu(sum))
}

func FromSnafu(s string) int {
	result := 0
	for len(s) > 0 {
		digit, err := strconv.Atoi(string(s[0]))
		if err != nil && s[0] == '=' {
			digit = -2
		} else if err != nil && s[0] == '-' {
			digit = -1
		}

		result += digit * int(math.Pow(5, float64(len(s)-1)))

		s = s[1:]
	}

	return result
}

func ToSnafu(d int) string {
	result := ""
	digit := int(math.Pow(float64(d), (1.0/5.0))) + 1
	for digit >= 0 {
		fives := math.Pow(5, float64(digit))
		amtUsed := float64(d) / fives
		if amtUsed >= 1.5 {
			result += "2"
			d -= 2 * int(fives)
		} else if amtUsed >= 0.5 {
			result += "1"
			d -= int(fives)
		} else if amtUsed > -.5 {
			if result != "" {
				result += "0"
			}
		} else if amtUsed > -1.5 {
			result += "-"
			d -= -1 * int(fives)
		} else {
			result += "="
			d -= -2 * int(fives)
		}

		digit--
	}

	return result
}
