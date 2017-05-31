//: [Previous](@previous)

import Foundation
import Surge
import minimind

//: [Next](@next)

let kern = RBF(alpha: 0.1, gamma: 2.0)
let gpr = GaussianProcessRegressor<Float, RBF>(kernel: kern, alpha: 0.01)

let X: Matrix<Float> = randMatrix(rows: 10, columns: 5)
let y: Matrix<Float> = randMatrix(rows: 10, columns: 1)

gpr.fit(X, y)

let Xstar: Matrix<Float> = randMatrix(rows: 2, columns: 5)
gpr.predict(Xstar)
