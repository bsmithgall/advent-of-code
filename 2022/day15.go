package main

import (
	"fmt"
	"regexp"
	"sort"
	"strconv"
)

func DayFifteen(skip bool) {
	if skip {
		return
	}

	input := ReadLines("day-15")

	fmt.Printf("Positions where beacon cannot be present: %d\n", DayFifteenOne(input, 2000000))
	fmt.Printf("Tuning Frequency: %d\n", DayFifteenTwo(input, 4000000, 4000000))
}

func DayFifteenOne(input []string, row int) int {
	intersects := []DistressSegment{}
	total := 0

	for _, line := range input {
		s := ToSensor(line)
		overlap, ok := s.Zone().HorizontalIntersection(row)
		if ok {
			intersects = append(intersects, overlap)
		}
	}

	sort.Slice(intersects, func(i, j int) bool {
		return intersects[i].start.x < intersects[j].start.x
	})

	nonContaining := []DistressSegment{}

	for i := 0; i < len(intersects); i++ {
		candidate := intersects[i]
		containedByAny := false
		for j := 0; j < len(intersects); j++ {
			if i == j {
				continue
			}
			if candidate.ContainedBy(intersects[j]) {
				containedByAny = true
				break
			}
		}
		if !containedByAny {
			nonContaining = append(nonContaining, candidate)
		}
	}

	for i := 1; i < len(nonContaining); i++ {
		removed := nonContaining[i-1].MinusHorizontalOverlap(nonContaining[i])
		total += removed.end.x - removed.start.x
	}

	last := nonContaining[len(nonContaining)-1]
	total += last.end.x - last.start.x

	return total
}

func DayFifteenTwo(input []string, maxX int, maxY int) int {
	sensors := make([]Sensor, len(input))
	found := DistressCoord{}

	for idx, line := range input {
		sensors[idx] = ToSensor(line)
	}

ySearch:
	for y := 0; y < maxY; y++ {
	xSearch:
		for x := 0; x <= maxX; x++ {
			for _, sensor := range sensors {
				// if this particular coordinate is seen by a sensor
				if sensor.size > sensor.Manhattan(DistressCoord{x, y}) {
					// skip ahead in the x-space search by the amount remaining
					x = sensor.x + sensor.RemainingHorizontal(y)
					// the beacon would be one outside of the search space
					found.x = x + 1
					continue xSearch
				}
			}
			// you've gone too far! go on to the next row and try again
			if found.x >= maxX {
				continue ySearch
			}
			found.y = y
			break ySearch
		}
	}

	return found.TuningFrequency()
}

type DistressCoord struct{ x, y int }

func (c DistressCoord) TuningFrequency() int {
	return c.x*4000000 + c.y
}

type DistressSegment struct {
	start, end DistressCoord
}

// Return the segment with any overlap from another segment stripped off.
// Assumes that s.start < o.start
func (s DistressSegment) MinusHorizontalOverlap(o DistressSegment) DistressSegment {
	if s.end.x < o.start.x {
		return s
	}

	return DistressSegment{
		start: s.start,
		end:   DistressCoord{x: o.start.x, y: s.end.y},
	}
}

// Is this segment completely contained by another segment?
func (s DistressSegment) ContainedBy(o DistressSegment) bool {
	return s.start.x >= o.start.x && s.end.x <= o.end.x
}

type SensorZone struct {
	N, S, E, W DistressCoord
	sensor     *Sensor
	size       int
}

// For part one: we need to figure out which points sensors can see along a
// line. Given a diamond-shaped zone, return a horizontal line segment
// representing the parts of that zone intersected by the line. If the line
// doesn't intersect at all, return (_, false)
func (z SensorZone) HorizontalIntersection(y int) (DistressSegment, bool) {
	intersection := DistressSegment{}

	if !(z.N.y > y && y > z.S.y) {
		return intersection, false
	}

	// if the diamond has a manhattan size around of 10 and the line is three
	// points up from the center, it can go six in either direction (10 includes
	// the beacon)
	remaining := z.sensor.RemainingHorizontal(y)
	intersection.start = DistressCoord{z.sensor.x - remaining, y}
	intersection.end = DistressCoord{z.sensor.x + remaining, y}

	return intersection, true
}

type Sensor struct {
	x, y, size int
	beacon     DistressCoord
}

func (s Sensor) Manhattan(o DistressCoord) int {
	return Abs(s.x-o.x) + Abs(s.y-o.y)
}

// given a point along the X axis inside the sensor's zone, calculate how much
// remaining manhattan distance is left after factoring out that point
func (s Sensor) RemainingHorizontal(y int) int {
	return s.size - Abs(s.y-y)
}

func (s Sensor) Zone() SensorZone {
	return SensorZone{
		N:      DistressCoord{s.x, s.y + s.size},
		S:      DistressCoord{s.x, s.y - s.size},
		E:      DistressCoord{s.x + s.size, s.y},
		W:      DistressCoord{s.x - s.size, s.y},
		sensor: &s,
		size:   s.size,
	}
}

func ToSensor(input string) Sensor {
	r := regexp.MustCompile(`Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)`)
	match := r.FindStringSubmatch(input)

	parsed := make([]int, 4)

	for i := 1; i < len(match); i++ {
		val, _ := strconv.Atoi(match[i])
		parsed[i-1] = val

	}

	sensor := Sensor{x: parsed[0], y: parsed[1], beacon: DistressCoord{parsed[2], parsed[3]}}
	sensor.size = sensor.Manhattan(sensor.beacon)

	return sensor
}
