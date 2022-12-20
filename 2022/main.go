package main

import (
	"fmt"
	"time"
)

func main() {
	start := time.Now()
	DayTwenty(false)
	DayNineteen(true)
	DayEighteen(true)
	DaySeventeen(true)
	DaySixteen(true)
	DayFifteen(true)
	DayFourteen(true)
	DayThirteen(true)
	DayTwelve(true)
	DayEleven(true)
	DayTen(true)
	DayNine(true)
	DayEight(true)
	DaySeven(true)
	DaySix(true)
	DayFive(true)
	DayFour(true)
	DayThree(true)
	DayTwo(true)
	DayOne(true)
	fmt.Printf("Finished! (took %s)\n", time.Since(start))
}
