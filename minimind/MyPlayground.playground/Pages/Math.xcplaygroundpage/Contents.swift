//: [Previous](@previous)

import Foundation
import minimind

var str = "Hello, playground"

//: [Next](@next)

let V: Matrix<Double> = linspace(-1.0, 2.0, 5)
let x = linspace(-1.0, 2.0, 5)

let A: Matrix<Float> = randMatrix(3, 3)
print(tril(A))