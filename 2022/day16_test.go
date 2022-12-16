package main

import (
	"reflect"
	"testing"
)

var inputSixteen = []string{
	"Valve AA has flow rate=0; tunnels lead to valves DD, II, BB",
	"Valve BB has flow rate=13; tunnels lead to valves CC, AA",
	"Valve CC has flow rate=2; tunnels lead to valves DD, BB",
	"Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE",
	"Valve EE has flow rate=3; tunnels lead to valves FF, DD",
	"Valve FF has flow rate=0; tunnels lead to valves EE, GG",
	"Valve GG has flow rate=0; tunnels lead to valves FF, HH",
	"Valve HH has flow rate=22; tunnel leads to valve GG",
	"Valve II has flow rate=0; tunnels lead to valves AA, JJ",
	"Valve JJ has flow rate=21; tunnel leads to valve II",
}

func TestDaySixteenOne(t *testing.T) {
	result := DaySixteenOne(inputSixteen)

	if result != 1651 {
		t.Errorf("Expected 1651, got %d", result)
	}
}

func TestDaySixteenTwo(t *testing.T) {
	result := DaySixteenTwo(inputSixteen)

	if result != 1707 {
		t.Errorf("Expected 1707, got %d", result)
	}
}

func TestDaySixteenParse(t *testing.T) {
	resultT, resultR := DaySixteenParse(inputSixteen)

	expectedEdges := []Tunnel{
		{from: 0, to: "DD", weight: 1},
		{from: 0, to: "II", weight: 1},
		{from: 0, to: "BB", weight: 1},
	}

	for i, e := range resultT[0] {
		if !reflect.DeepEqual(e, expectedEdges[i]) {
			t.Errorf("Expected %v, got %v", e, expectedEdges[i])

		}
	}

	if resultR["BB"].flow != 13 {
		t.Errorf("Expected 13, got %d", resultR["BB"].flow)
	}
}
