package main

import (
	"fmt"
	"math"
	"strconv"
	"strings"
)

func DaySeven(skip bool) {
	if skip {
		return
	}

	input := ReadLines("day-7")
	fmt.Printf("Total deletion candidate size %d\n", DaySevenOne(input))
	fmt.Printf("Smallest directory that can be deleted %d\n", DaySevenTwo(input))
}

func DaySevenOne(input []string) int {
	root := DaySevenParse(input)

	deletionCandidatesSize := 0
	maxDeletionSize := 100000

	for _, v := range root.AllSizes() {
		if v <= maxDeletionSize {
			deletionCandidatesSize += v
		}
	}

	return deletionCandidatesSize
}

func DaySevenTwo(input []string) int {
	root := DaySevenParse(input)

	deletionCandidateSize := math.MaxInt

	allSizes := root.AllSizes()
	sizeNeeded := allSizes["root/"] - (70000000 - 30000000)

	for _, v := range allSizes {
		if v > sizeNeeded && v < deletionCandidateSize {
			deletionCandidateSize = v
		}
	}

	return deletionCandidateSize
}

func DaySevenParse(input []string) Directory {
	current := &Directory{"root", nil, make(map[string]*Directory), []File{}}

	for _, cmd := range input {
		switch {
		case strings.HasPrefix(cmd, "$ cd "):
			parts := strings.Split(cmd, " ")
			name := parts[2]
			switch name {
			case "/":
				for {
					if current.parent == nil {
						break
					}
					current = current.parent
				}
			case "..":
				current = current.parent
			default:
				current = current.children[name]
			}
		case strings.HasPrefix(cmd, "$ ls"):
			continue
		case strings.HasPrefix(cmd, "dir"):
			parts := strings.Split(cmd, " ")
			current.children[parts[1]] = &Directory{parts[1], current, make(map[string]*Directory), []File{}}
		default:
			parts := strings.Split(cmd, " ")
			size, _ := strconv.Atoi(parts[0])
			current.files = append(current.files, File{parts[1], size})
		}
	}
	for {
		if current.parent == nil {
			return *current
		}
		current = current.parent
	}
}

type File struct {
	name string
	size int
}

type Directory struct {
	name     string
	parent   *Directory
	children map[string]*Directory
	files    []File
}

func (d Directory) Name() string {
	name := ""
	current := &d
	for {
		name = current.name + "/" + name
		if current.parent == nil {
			return name
		}
		current = current.parent
	}
}

func (d Directory) Size() int {
	size := 0

	for _, f := range d.files {
		size += f.size
	}

	for _, c := range d.children {
		size += c.Size()
	}

	return size
}

func (d Directory) AllSizes() map[string]int {
	allSizes := make(map[string]int)

	for _, c := range d.children {
		for k, v := range c.AllSizes() {
			allSizes[k] = v
		}
	}

	allSizes[d.Name()] = d.Size()

	return allSizes
}
