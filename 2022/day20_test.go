package main

import (
	"reflect"
	"testing"
)

var inputTwenty = Encrypted{[]PuzzleNum{{0, 1}, {1, 2}, {2, -3}, {3, 3}, {4, -2}, {5, 0}, {6, 4}}}

func TestMix(t *testing.T) {
	resultEnc := Mix(inputTwenty)
	result := []int{}
	for _, num := range resultEnc.nums {
		result = append(result, num.val)
	}

	// this isn't technically _exactly_ what is in the example, but it doesn't
	// actually matter because it's a circle :)
	expected := []int{-2, 1, 2, -3, 4, 0, 3}

	if !reflect.DeepEqual(result, expected) {
		t.Errorf("Expected %v, got %v", expected, result)
	}
}
