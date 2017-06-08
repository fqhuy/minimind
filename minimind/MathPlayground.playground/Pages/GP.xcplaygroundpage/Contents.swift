//: [Previous](@previous)

import Foundation

var str = "Hello, playground"
//: [Next](@next)

import Surge
import minimind



let N = 8
let P = 2
let w = Float(300.0)

let x: [Float] = arange(0.0, w, w / Float(N))
var s1 = sin(x)
var s2 = cos(x)
s1 -= s1.mean(); s1 /= s1.std()
s2 -= s2.mean(); s2 /= s2.std()

let kern = RBF(alpha: 10.1, gamma: 10.0)
let gpr = GaussianProcessRegressor<Float, RBF>(kernel: kern, alpha: 10.01)

var X: Matrix<Float> = zeros(N, P+1)
X[column: 0] = [Float](repeating: 1.0, count: N)
X[column: 1] = s1
X[column: 2] = s2
var XX: Matrix<Float> = zeros(N, P)

for i in 1..<P+1 {
    XX[column: i - 1] = X[column: i]
}

let A: Matrix<Float> = randMatrix(P + 1, 1)
let y: Matrix<Float> = X * A + 0.1 * randMatrix(N, 1)

gpr.fit(XX, y)

let Xstar: Matrix<Float> = randMatrix(5, P)
let (Mu, Sigma) = gpr.predict(Xstar)

print(Mu)
