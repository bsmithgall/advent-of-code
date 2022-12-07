package main

import (
	"testing"
)

var inputSeven = []string{
	"$ cd /",
	"$ ls",
	"dir a",
	"14848514 b.txt",
	"8504156 c.dat",
	"dir d",
	"$ cd a",
	"$ ls",
	"dir e",
	"29116 f",
	"2557 g",
	"62596 h.lst",
	"$ cd e",
	"$ ls",
	"584 i",
	"$ cd ..",
	"$ cd ..",
	"$ cd d",
	"$ ls",
	"4060174 j",
	"8033020 d.log",
	"5626152 d.ext",
	"7214296 k",
}

func TestDaySevenOne(t *testing.T) {
	result := DaySevenOne(inputSeven)

	if result != 95437 {
		t.Errorf("Expected 95437, got %d", result)
	}
}

func TestDaySevenTwo(t *testing.T) {
	result := DaySevenTwo(inputSeven)

	if result != 24933642 {
		t.Errorf("Expected 24933642, got %d", result)
	}
}

func TestDaySevenParse(t *testing.T) {
	result := DaySevenParse(inputSeven)

	if result.name != "root" {
		t.Errorf("Invalid root")
	}

	if len(result.children) != 2 {
		t.Errorf("Invalid root children")
	}

	if len(result.files) != 2 {
		t.Errorf("Invalid root files")
	}

	expectedSize := result.Size()
	if expectedSize != 48381165 {
		t.Errorf("Invalid size! Expected 48381165, got %d", expectedSize)
	}
}
