//: [Previous](@previous)

import Foundation
import minimind

var str = "Hello, playground"

//: [Next](@next)

let v: [Float] = [0.1, 0.3, 0.5, 0.9]
let a: [Float] = [0.0, 0.2, 0.4, 1.2]

//print(searchsorted(v, a))

let x = Matrix<Float>([[1, 1], [2, 2]])
x.apply({x, y in x * y }, Array<Float>([5.0, 10.0]), 0)
