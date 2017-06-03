//: [Previous](@previous)

import Foundation
import Surge
import minimind

var str = "Hello, playground"

//: [Next](@next)

let mat: Matrix<Float> = Matrix<Float>([[0.1, 0.4, 0.3],[0.2, 0.1, 0.1]]).t
let A: Matrix<Float> = mat * mat.t + eye(3)
let v = Matrix<Float>([[0.0, 0.0, 0.0]])

let gauss = MultivariateNormal(v, A)

print(gauss.rvs(10))
print(gauss.pdf(randMatrix(10, 3)))

