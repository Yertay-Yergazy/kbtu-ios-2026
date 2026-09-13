// MARK: - Easy Tasks

// 1. Array Creation and Access
let fruits = ["apple", "banana", "cherry", "date", "elderberry"]
print("Third fruit: \(fruits[2])")

// 2. Set Creation and Manipulation
var favoriteNumbers: Set<Int> = [3, 7, 21]
favoriteNumbers.insert(42)
print("Favorite numbers: \(favoriteNumbers)")

// 3. Dictionary Creation and Access
let releaseYears = ["Swift": 2014, "Python": 1991, "Java": 1995]
print("Swift release year: \(releaseYears["Swift"]!)")

// 4. Array Element Update
var colors = ["red", "green", "blue", "yellow"]
colors[1] = "purple"
print("Updated colors: \(colors)")

// MARK: - Medium Tasks

// 1. Set Intersection
let setA: Set = [1, 2, 3, 4]
let setB: Set = [3, 4, 5, 6]
print("Intersection: \(setA.intersection(setB))")

// 2. Dictionary Update
var scores = ["Aidar": 85, "Dana": 92, "Timur": 78]
scores.updateValue(90, forKey: "Timur")
print("Updated scores: \(scores)")

// 3. Array Merge
let firstArray = ["apple", "banana"]
let secondArray = ["cherry", "date"]
let mergedArray = firstArray + secondArray
print("Merged array: \(mergedArray)")

// MARK: - Hard Tasks

// 1. Dictionary Key Addition
var populations = ["Kazakhstan": 20_000_000, "Japan": 125_000_000]
populations["Germany"] = 84_000_000
print("Updated populations: \(populations)")

// 2. Set Union and Subtract
let firstSet: Set = ["cat", "dog"]
let secondSet: Set = ["dog", "mouse"]
let result = firstSet.union(secondSet).subtracting(secondSet)
print("Final set: \(result)")

// 3. Nested Collection
let grades = [
    "Aibar": [90, 85, 77],
    "Akezh": [95, 88, 92]
]
print("Aibar's second grade: \(grades["Aibar"]![1])")
