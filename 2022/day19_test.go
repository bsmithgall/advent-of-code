package main

import "testing"

var inputNineteen = []string{
	"Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.",
	"Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.",
}

func TestDayNineteenOne(t *testing.T) {
	blueprints := []Blueprint{}
	for _, line := range inputNineteen {
		blueprints = append(blueprints, ToBlueprint(line))
	}

	result := DayNineteenOne(blueprints)

	if result != 33 {
		t.Errorf("Expcted 33, got %d", result)
	}
}

func TestDayNineteenTwo(t *testing.T) {
	blueprints := []Blueprint{}
	for _, line := range inputNineteen {
		blueprints = append(blueprints, ToBlueprint(line))
	}

	result := DayNineteenTwo(blueprints)
	if result != 56*62 {
		t.Errorf("Expected %d, got %d", 56*62, result)
	}
}
