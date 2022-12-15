package main

import (
	"testing"
)

var inputFifteen = []string{
	"Sensor at x=8, y=7: closest beacon is at x=2, y=10",
	"Sensor at x=2, y=18: closest beacon is at x=-2, y=15",
	"Sensor at x=9, y=16: closest beacon is at x=10, y=16",
	"Sensor at x=13, y=2: closest beacon is at x=15, y=3",
	"Sensor at x=12, y=14: closest beacon is at x=10, y=16",
	"Sensor at x=10, y=20: closest beacon is at x=10, y=16",
	"Sensor at x=14, y=17: closest beacon is at x=10, y=16",
	"Sensor at x=2, y=0: closest beacon is at x=2, y=10",
	"Sensor at x=0, y=11: closest beacon is at x=2, y=10",
	"Sensor at x=20, y=14: closest beacon is at x=25, y=17",
	"Sensor at x=17, y=20: closest beacon is at x=21, y=22",
	"Sensor at x=16, y=7: closest beacon is at x=15, y=3",
	"Sensor at x=14, y=3: closest beacon is at x=15, y=3",
	"Sensor at x=20, y=1: closest beacon is at x=15, y=3",
}

func TestFifteenOne(t *testing.T) {
	result := DayFifteenOne(inputFifteen, 10)

	if result != 26 {
		t.Errorf("Expected 26, got %d", result)
	}
}

func TestFifteenTwo(t *testing.T) {
	result := DayFifteenTwo(inputFifteen, 20, 20)

	if result != 56000011 {
		t.Errorf("Expected 56000011, got %d", result)
	}
}

func TestHorizontalOverlap(t *testing.T) {
	sensor := ToSensor(inputFifteen[0])
	result, _ := sensor.Zone().HorizontalIntersection(10)

	expected := DistressSegment{DistressCoord{2, 10}, DistressCoord{14, 10}}
	if result != expected {
		t.Errorf("Expected %#v, got %#v", expected, result)
	}
}

func TestToSensor(t *testing.T) {
	sensor := ToSensor(inputFifteen[0])

	expectedSensor := Sensor{8, 7, 9, DistressCoord{2, 10}}
	if sensor != expectedSensor {
		t.Errorf("Expected %#v, Got %#v", expectedSensor, sensor)
	}
}
