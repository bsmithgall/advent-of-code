package main

import (
	"fmt"
	"math"
	"strconv"
	"strings"
)

func DayTwentyOne(skip bool) {
	if skip {
		return
	}

	input := ReadLines("day-21")

	fmt.Println("Root monkey will yell:", DayTwentyOneOne(input))
	fmt.Println("Root monkey equality test:", DayTwentyOneTwo(input))
}

func DayTwentyOneOne(input []string) int {
	monkeyMap := ToMonkeyMap(input)
	return monkeyMap["root"].Resolve()
}

func DayTwentyOneTwo(input []string) int {
	monkeyMap := ToMonkeyMap(input)
	root := monkeyMap["root"]
	left, right := root.left.FindHumn(), root.right.FindHumn()
	if left == math.MinInt {
		return root.left.ResolveHumn(right)
	}
	if right == math.MinInt {
		return root.right.ResolveHumn(left)
	}

	return -1
}

type Monkey21 struct {
	name, op    string
	val         int
	left, right *Monkey21
}

func ToMonkeyMap(input []string) map[string]*Monkey21 {
	result := make(map[string]*Monkey21)

	for _, row := range input {
		parts := strings.Split(row, ": ")
		monkey, exists := result[parts[0]]
		if !exists {
			monkey = &Monkey21{name: parts[0]}
		}
		if num, err := strconv.Atoi(parts[1]); err == nil {
			monkey.val = num
		} else {
			rightParts := strings.Split(parts[1], " ")
			monkey.op = rightParts[1]

			left, leftOk := result[rightParts[0]]
			if !leftOk {
				left = &Monkey21{name: rightParts[0]}
				result[rightParts[0]] = left
			}
			monkey.left = left

			right, rightOk := result[rightParts[2]]
			if !rightOk {
				right = &Monkey21{name: rightParts[2]}
				result[rightParts[2]] = right
			}
			monkey.right = right
		}

		result[monkey.name] = monkey
	}

	return result
}

func (m Monkey21) Resolve() int {
	result := 0
	if m.left == nil && m.right == nil {
		return m.val
	}
	switch m.op {
	case "+":
		result = m.left.Resolve() + m.right.Resolve()
	case "-":
		result = m.left.Resolve() - m.right.Resolve()
	case "*":
		result = m.left.Resolve() * m.right.Resolve()
	case "/":
		result = m.left.Resolve() / m.right.Resolve()
	}

	return result
}

// Here we are tryign to work backwards to make the left side of the tree
// balance against the right side of the tree.
func (m Monkey21) ResolveHumn(wants int) int {
	result := 0
	if m.name == "humn" {
		return wants
	}

	left, right := m.left.FindHumn(), m.right.FindHumn()

	// left side of the tree contains missing "humn" value, so you end up with
	// something like `wants = humn op right`, which converts to `humn = wants
	// inverse op right`
	if left == math.MinInt {
		switch m.op {
		case "+":
			return m.left.ResolveHumn(wants - right)
		case "-":
			return m.left.ResolveHumn(wants + right)
		case "*":
			return m.left.ResolveHumn(wants / right)
		case "/":
			return m.left.ResolveHumn(wants * right)
		}
		// same as above, but with right side of the tree so it's a bit more complicated
	} else {
		switch m.op {
		case "+":
			return m.right.ResolveHumn(wants - left)
		case "-":
			return m.right.ResolveHumn(left - wants)
		case "*":
			return m.right.ResolveHumn(wants / left)
		case "/":
			return m.right.ResolveHumn(left / wants)
		}

	}

	return result
}

func (m Monkey21) FindHumn() int {
	if m.name == "humn" {
		return math.MinInt
	}

	if m.left == nil && m.right == nil {
		return m.val
	}

	left, right := m.left.FindHumn(), m.right.FindHumn()
	if left != math.MinInt && right != math.MinInt {
		switch m.op {
		case "+":
			return left + right
		case "-":
			return left - right
		case "*":
			return left * right
		case "/":
			return left / right
		}
	}

	return math.MinInt
}
