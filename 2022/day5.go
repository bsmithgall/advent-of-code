package main

import (
	"fmt"
	"strconv"
	"strings"
)

func DayFive(skip bool) {
	if skip {
		return
	}

	input := Read("day-5")
	fmt.Printf("Message after CrateMover9000: \"%s\"\n", DayFiveOne(input))
	fmt.Printf("Message after CrateMover9001: \"%s\"\n", DayFiveTwo(input))
}

func DayFiveOne(input string) string {
	stacks, instructions := DayFiveParse(input)

	for _, instruction := range instructions {
		stacks = stacks.Move9000(instruction)
	}

	return stacks.Message()
}

func DayFiveTwo(input string) string {
	stacks, instructions := DayFiveParse(input)

	for _, instruction := range instructions {
		stacks = stacks.Move9001(instruction)
	}

	return stacks.Message()
}

func DayFiveParse(input string) (Stacks, []CrateInstruction) {
	parts := strings.Split(input, "\n\n")
	stacksStr, instructionsStr := strings.Split(parts[0], "\n"), strings.Split(parts[1], "\n")

	return parseStacks(stacksStr), parseInstructions(instructionsStr)
}

func parseStacks(stacksStr []string) Stacks {
	// []string{1, 2, 3, ...}
	// [SBW] - since the lines are very evenly spaced, you could probably simplify this a smidge
	// by using (line_lenth+1) / spaces_a_crate_takes (the +1 is for a space after the last crate)
	// it really just depends on what you think is easier to follow (but this is a little tough to read)
	labelRow := strings.Split(strings.Replace(stacksStr[len(stacksStr)-1], " ", "", -1), "")
	numStacks, _ := strconv.Atoi(labelRow[len(labelRow)-1])
	stacks := make(Stacks, numStacks)

	// [SBW] - for the same reason as the note above, you know the index of each crate because they're consistently spaced
	/*
	for i := 0; i < len(stacks); i++ {
		container := string(line[(i*4)+1]) // each crate takes 4 spaces; skip the first cuz it's a '['
		if container != " " {
			stacks[i] = append(stacks[i], container)
		}

	}
	*/
	for i := 0; i < len(stacksStr)-1; i++ {
		stackStr := stacksStr[i]

		// chomp the string container by container til it's empty
		for j := 0; j < numStacks; j++ {
			container := stackStr[0:3]
			stackStr = stackStr[3:]
			if string(container[1]) != " " {
				stacks[j] = append(stacks[j], string(container[1]))
			}

			if len(stackStr) > 1 {
				stackStr = stackStr[1:]
			}

		}
	}

	return stacks
}

func parseInstructions(instructionsStr []string) []CrateInstruction {
	instructions := make([]CrateInstruction, len(instructionsStr))

	for idx, str := range instructionsStr {
		// [SBW] - you should look into fmt.Sscanf
		// for example...
		/*
		var amount, from, to int
		n, err := fmt.Sscanf(str, "move %d from %d to %d", &amount, &from, &to)
		if err != nil {
			panic(err)
		}
		if n != 3 {
			panic("line didn't have the right number of fields matched")
		}
		*/
		parts := strings.Split(str, " ")
		amount, _ := strconv.Atoi(parts[1])
		from, _ := strconv.Atoi(parts[3])
		to, _ := strconv.Atoi(parts[5])
		instructions[idx] = CrateInstruction{amount, from - 1, to - 1}
	}

	return instructions
}

type CrateInstruction struct {
	amount int
	from   int
	to     int
}

type Stacks [][]string

func (s Stacks) Move9000(instruction CrateInstruction) Stacks {
	for i := 0; i < instruction.amount; i++ {
		value := s[instruction.from][0]
		s[instruction.from] = s[instruction.from][1:]
		s[instruction.to] = append([]string{value}, s[instruction.to]...)
	}
	return s
}

func (s Stacks) Move9001(instruction CrateInstruction) Stacks {
	value := s[instruction.from][0:instruction.amount]
	newTo := []string{}
	newTo = append(newTo, value...)
	newTo = append(newTo, s[instruction.to]...)
	s[instruction.to] = newTo
	s[instruction.from] = s[instruction.from][instruction.amount:]
	return s
}

func (s Stacks) Message() string {
	message := ""

	for idx := range s {
		if len(s[idx]) > 0 {
			message += s[idx][0]
		} else {
			message += " "
		}
	}

	return message
}
