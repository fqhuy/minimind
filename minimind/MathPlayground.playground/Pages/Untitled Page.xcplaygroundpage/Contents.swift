//: [Previous](@previous)

import Foundation
import minimind

var str = "Hello, playground"

//: [Next](@next)

let v1: [Float] = [0.1, 0.3, 0.5, 0.9]
let v2: [Float] = [0.0, 0.2, 0.4, 1.2]
100

let v = [v1, v2, v1]
let cv = v.reduce([], {x, y in x ∪ y})
print(cv)

var d = ["a": 10, "b": 9]
d["c"] = 7

print(d)