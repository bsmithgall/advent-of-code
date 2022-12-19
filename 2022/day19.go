package main

import (
	"fmt"
	"math"
)

func DayNineteen(skip bool) {
	if skip {
		return
	}

	input := ReadLines("day-19")

	blueprints := []Blueprint{}

	for _, line := range input {
		blueprints = append(blueprints, ToBlueprint(line))
	}

	fmt.Println("Blueprint quality level summation:", DayNineteenOne(blueprints))
	fmt.Println("Maximum blueprint values", DayNineteenTwo(blueprints[0:3]))
}

func DayNineteenOne(blueprints []Blueprint) int {
	sum := 0
	maxTime := 24

	for _, blueprint := range blueprints {
		maxRobots := [4]int{-1, -1, -1, math.MaxInt}
		for _, robot := range blueprint.robots {
			for idx, ore := range robot.ores {
				if ore > maxRobots[idx] {
					maxRobots[idx] = ore
				}
			}
		}

		sum += blueprint.Simulate(InitialState(), maxTime, maxRobots, 0) * blueprint.idx
	}

	return sum
}

func DayNineteenTwo(blueprints []Blueprint) int {
	product := 1
	maxTime := 32

	for _, blueprint := range blueprints {
		maxRobots := [4]int{-1, -1, -1, math.MaxInt}
		for _, robot := range blueprint.robots {
			for idx, ore := range robot.ores {
				if ore > maxRobots[idx] {
					maxRobots[idx] = ore
				}
			}
		}
		product *= blueprint.Simulate(InitialState(), maxTime, maxRobots, 0)
	}

	return product
}

type Robot struct {
	ores [4]int
}

type Blueprint struct {
	idx    int
	robots [4]Robot
}

func (b Blueprint) Simulate(state SimulationState, maxTime int, maxRobots [4]int, maxGeodes int) int {
	robotConstructed := false

	// for each robot type...
	for robotTypeIdx := 0; robotTypeIdx < 4; robotTypeIdx++ {
		// skip if we are already maxed out on this type of robot
		if state.robotCount[robotTypeIdx] == maxRobots[robotTypeIdx] {
			continue
		}

		robot := b.robots[robotTypeIdx]
		oreCosts := [3]int{-1, -1, -1}
		maxTimeToBuildRobot := 0

		// figure out which ore is going to be the limiting factor
		for oreTypeIdx := 0; oreTypeIdx < 3; oreTypeIdx++ {
			oreCost := robot.ores[oreTypeIdx]
			// make sure we actually need
			if oreCost == 0 {
				// no-op
				oreCosts[oreTypeIdx] = -1
			} else if oreCost <= state.oreCount[oreTypeIdx] {
				oreCosts[oreTypeIdx] = 0
			} else if state.robotCount[oreTypeIdx] == 0 {
				// we don't have a robot to build this yet, and we can't ever afford to
				// build one!
				oreCosts[oreTypeIdx] = maxTime + 1
			} else {
				// we can make another robot for the given ore type!
				oreCosts[oreTypeIdx] = (oreCost - state.oreCount[oreTypeIdx] + state.robotCount[oreTypeIdx] - 1) / state.robotCount[oreTypeIdx]
			}
		}

		for i := range oreCosts {
			if oreCosts[i] > maxTimeToBuildRobot {
				maxTimeToBuildRobot = oreCosts[i]
			}
		}

		finishedAt := state.time + maxTimeToBuildRobot + 1
		if finishedAt > maxTime {
			continue
		}

		newOres, newRobots := [4]int{}, [4]int{}
		for i := 0; i < 4; i++ {
			newOres[i] = state.oreCount[i] + state.robotCount[i]*(maxTimeToBuildRobot+1) - robot.ores[i]
			newRobots[i] = state.robotCount[i]
			if i == robotTypeIdx {
				newRobots[i] = newRobots[i] + 1
			}
		}

		timeRemaining := maxTime - finishedAt

		// if we _only_ built geodes at this point, could we do any better than we
		// currently are doing? if not, break early
		if ((timeRemaining-1)*timeRemaining)/2+newOres[3]+(timeRemaining*newRobots[3]) < maxGeodes {
			continue
		}

		robotConstructed = true
		simulated := b.Simulate(SimulationState{newOres, newRobots, finishedAt}, maxTime, maxRobots, maxGeodes)
		if simulated > maxGeodes {
			maxGeodes = simulated
		}
	}

	// no additional robots were able to be constructed, so we are at the best
	// possible point in the branch.
	if !robotConstructed {
		makeableGeodes := state.MakeableGeodes(maxTime)
		if makeableGeodes > maxGeodes {
			maxGeodes = makeableGeodes
		}
	}

	return maxGeodes
}

type SimulationState struct {
	oreCount   [4]int
	robotCount [4]int
	time       int
}

func (s SimulationState) MakeableGeodes(maxTime int) int {
	return s.oreCount[3] + s.robotCount[3]*(maxTime-s.time)
}

func InitialState() SimulationState {
	return SimulationState{
		[4]int{0, 0, 0, 0},
		[4]int{1, 0, 0, 0},
		0,
	}
}

func ToBlueprint(line string) Blueprint {
	var idx, oOre, cOre, obOre, obClay, gOre, gObsidian int
	n, err := fmt.Sscanf(line, "Blueprint %d: Each ore robot costs %d ore. Each clay robot costs %d ore. Each obsidian robot costs %d ore and %d clay. Each geode robot costs %d ore and %d obsidian.", &idx, &oOre, &cOre, &obOre, &obClay, &gOre, &gObsidian)
	if err != nil {
		panic(err)
	}
	if n != 7 {
		panic("matched incorrect number of fields")
	}

	return Blueprint{
		idx,
		[4]Robot{
			{[4]int{oOre, 0, 0, 0}},
			{[4]int{cOre, 0, 0, 0}},
			{[4]int{obOre, obClay, 0, 0}},
			{[4]int{gOre, 0, gObsidian, 0}},
		},
	}
}
