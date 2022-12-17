package main

import (
	"fmt"
	"math"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"sync"
)

func DaySixteen(skip bool) {
	if skip {
		return
	}

	input := ReadLines("day-16")

	fmt.Println("Most possible pressure released:", DaySixteenOne(input))
	fmt.Println("Most possible pressure released (with Pacyderm Partner):", DaySixteenTwo(input))
}

func DaySixteenOne(input []string) int {
	tunnels, rooms := DaySixteenParse(input)

	allToAll := AllToAll(tunnels, rooms)
	withFlow := GetEligibleRooms(rooms)

	initialState := TraversalState{
		0, 30, 0, 0, rooms["AA"], rooms, allToAll,
	}

	return TraversePath(initialState, withFlow)
}

// the idea here is that we need to build the two unique sub-graphs that
// maximize the release pressure of the overall system. to do this, we should be
// able to get every unique combination of rooms with size < len(rooms) / 2,
// then get its mirror and feed that to the partner. the subgraph + its mirror
// represent one candidate of subgraphs to add together
func DaySixteenTwo(input []string) int {
	tunnels, rooms := DaySixteenParse(input)

	allToAll := AllToAll(tunnels, rooms)
	withFlow := GetEligibleRooms(rooms)

	max := 0

	mu := sync.Mutex{}
	var wg sync.WaitGroup

	for i := 1; i <= len(withFlow)/2; i++ {
		seen := make(map[string]bool)
		for _, subgraphA := range Combinations(withFlow, i) {
			wg.Add(1)
			go func(subgraphA []string) {
				subgraphB := Mirror(subgraphA, rooms)

				// if we are splitting in half, make sure we don't re-run over the same
				// subgraphs twice. i think this might only matter for the sample input
				// but /shrug
				if len(subgraphA) == len(subgraphB) {
					func() {
						mu.Lock()
						defer mu.Unlock()
						subgraphAStr := strings.Join(sort.StringSlice(subgraphA), "")
						subgraphBStr := strings.Join(sort.StringSlice(subgraphB), "")

						_, aOk := seen[subgraphAStr]
						_, bOk := seen[subgraphBStr]

						if !(aOk || bOk) {
							seen[subgraphAStr] = true
							seen[subgraphBStr] = true
						}
					}()
				}

				initialStateA := TraversalState{0, 26, 0, 0, rooms["AA"], rooms, allToAll}
				initialStateB := TraversalState{0, 26, 0, 0, rooms["AA"], rooms, allToAll}

				maxPressureA := TraversePath(initialStateA, subgraphA)
				maxPressureB := TraversePath(initialStateB, subgraphB)

				mu.Lock()
				if maxPressureA+maxPressureB > max {
					max = maxPressureA + maxPressureB
				}
				mu.Unlock()
				wg.Done()
			}(subgraphA)

		}
	}

	wg.Wait()
	return max
}

type Room struct {
	flow int
	name string
	idx  int
}
type Rooms map[string]Room
type Tunnel struct {
	from, weight int
	to           string
}

// Represent the graph as a matrix of tunnels. Each outer index repesents a
// room (rooms store this index on themselves), and each inner index represents
// a tunnel connecting two rooms
type TunnelMatrix = [][]Tunnel

func GetEligibleRooms(rooms Rooms) []string {
	eligible := []string{}

	for name, room := range rooms {
		if room.flow > 0 {
			eligible = append(eligible, name)
		}
	}

	return eligible
}

func DaySixteenParse(input []string) (TunnelMatrix, Rooms) {
	tunnels := make([][]Tunnel, len(input))
	rooms := make(map[string]Room)

	r := regexp.MustCompile(`Valve ([A-Z]+) has flow rate=(\d+); (tunnels lead to valves|tunnel leads to valve) ([A-Z\,\ ]+)`)

	for idx, line := range input {
		match := r.FindStringSubmatch(line)
		name := match[1]
		flowRate, _ := strconv.Atoi(match[2])

		neighbors := strings.Split(match[4], ", ")
		edges := make([]Tunnel, len(neighbors))

		rooms[name] = Room{name: name, flow: flowRate, idx: idx}

		for idn, n := range neighbors {
			edges[idn] = Tunnel{from: idx, to: n, weight: 1}
		}

		tunnels[idx] = edges
	}

	return tunnels, rooms
}

// implement the floyd-warshall algorithm to get the distance from all tunnels
// to all other tunnels. these distances are designed as an adjancency matrix.
func AllToAll(t TunnelMatrix, r Rooms) [][]float64 {
	allToAll := make([][]float64, len(t))

	// initialize the adjancency matrix
	for idy := range allToAll {
		inner := make([]float64, len(t))

		for idx := range inner {
			inner[idx] = math.Inf(1) // initialize each cell with the max value
		}
		// except for the diagonal, (rooms are dist. 0 from themselves)
		inner[idy] = 0
		allToAll[idy] = inner
	}

	// add all existing weights into the adjacency matrix. cannot be combined with
	// the above loop because the tunnel matrix is _not_ an adjancency matrix but
	// rather a graph represented as a matrix.
	for idy, tunnels := range t {
		for _, tunnel := range tunnels {
			allToAll[idy][r[tunnel.to].idx] = float64(tunnel.weight)
		}
	}

	// find the shortest path from node i to node j by checking every intermediate
	// node k between i and j. if the existing distance (represented by allToAll[i
	// index][j index], or allToAll[i][idj]) is less than traversing through node
	// k, include the traversal through node k
	for idk, k := range allToAll {
		for _, i := range allToAll {
			for idj, j := range i {
				distance := i[idk] + k[idj]
				if j > distance {
					i[idj] = distance
				}
			}
		}
	}

	return allToAll
}

type TraversalState struct {
	time, limit, flow, pressure int
	room                        Room
	rooms                       Rooms
	allToAll                    [][]float64
}

// the amount of pressure released if we do no additional traversals
func (t TraversalState) StopRelease() int {
	return t.pressure + (t.limit-t.time)*t.flow
}

// Recursively traverse every eligible path
func TraversePath(state TraversalState, remaining []string) int {
	max := state.StopRelease()

	for _, room := range remaining {
		newRoom := state.rooms[room]
		timeToMoveAndOpen := int(state.allToAll[state.room.idx][newRoom.idx] + 1)
		newTime := state.time + timeToMoveAndOpen
		// we have time to get to this tunnel
		if newTime < state.limit {
			newPressure := state.pressure + timeToMoveAndOpen*state.flow
			newFlow := state.flow + newRoom.flow
			newState := TraversalState{
				newTime, state.limit, newFlow, newPressure, newRoom, state.rooms, state.allToAll,
			}
			traversalScore := TraversePath(newState, RemoveRoom(remaining, room))
			if traversalScore > max {
				max = traversalScore
			}
		}

	}

	return max
}

func RemoveRoom(rooms []string, toRemove string) []string {
	remaining := []string{}

	for _, name := range rooms {
		if name != toRemove {
			remaining = append(remaining, name)
		}
	}

	return remaining
}

// given a slice of room names, return all rooms names not in that slice
func Mirror(roomNames []string, allRooms Rooms) []string {
	mirrored := []string{}

	roomNameMap := make(map[string]bool)
	for _, name := range roomNames {
		roomNameMap[name] = true
	}

	for name, room := range allRooms {
		if room.flow == 0 {
			continue
		}

		_, ok := roomNameMap[name]
		if !ok {
			mirrored = append(mirrored, name)
		}
	}

	return mirrored
}
