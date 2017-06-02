//: [Previous](@previous)

import Foundation
import Surge
import minimind

var str = "Hello, playground"

//: [Next](@next)

//let mat: Matrix<Float> = randMatrix(4, 3)
let mat: Matrix<Float> = Matrix<Float>([[0.1, 0.4, 0.3],[0.2, 0.1, 0.1]]).t
let symmat = mat * mat.t

let L = cholesky(symmat, "U")
print(L)
print(symmat)

let b: Matrix<Float> = Matrix<Float>([[0.1], [0.2], [0.3]])

let x = solve_triangular(L, b, "U")

print(x)
