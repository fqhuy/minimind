//: [Previous](@previous)

import Foundation
import minimind

var str = "Hello, playground"

//: [Next](@next)

let v1: [Float] = [0.1, 0.3, 0.5, 0.9]
let v2: [Float] = [0.0, 0.2, 0.4, 1.2]

let v3: [Bool] = [true, true, false]
let v4: [Bool] = [false, true, false]

func foo<T: ScalarType>(_ x: T, _ y: T) -> T {
    print("ScalarType")
    return x + y
}

func foo(_ x: Bool, _ y: Bool) -> Bool {
    print("Just Bool")
    return true
}

foo(10, 10)
foo(true, false)


let A = Matrix<String>([["a", "b"],["x", "y"]])
print(A)
print(transpose(A))

