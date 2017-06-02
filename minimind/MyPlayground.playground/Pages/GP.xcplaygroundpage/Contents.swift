//: [Previous](@previous)

import Foundation
import Surge
import minimind

//: [Next](@next)

let N = 8
let P = 2
let kern = RBF(alpha: 1.1, gamma: 1.0)
let gpr = GaussianProcessRegressor<Float, RBF>(kernel: kern, alpha: 1.01)

var X: Matrix<Float> = randMatrix(N, P + 1) * 5.0
X[column: 0] = [Float](repeating: 1.0, count: N)
var XX: Matrix<Float> = zeros(N, P)
for i in 1..<P+1 {
    XX[column: i - 1] = X[column: i]
}

let A: Matrix<Float> = randMatrix(P + 1, 1)
let y: Matrix<Float> = X * A + 0.01 * randMatrix(N, 1)

gpr.fit(XX, y)

let Xstar: Matrix<Float> = randMatrix(5, P)
let (Mu, Sigma) = gpr.predict(Xstar)

print(Mu)
