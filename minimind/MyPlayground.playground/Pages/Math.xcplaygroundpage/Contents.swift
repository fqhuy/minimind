//: [Previous](@previous)

import Foundation
import Surge
import minimind

var str = "Hello, playground"

//: [Next](@next)

//let mat: Matrix<Float> = Matrix<Float>([[0.1, 0.4, 0.3],[0.2, 0.1, 0.1]]).t
//let A: Matrix<Float> = mat * mat.t + eye(3)
//let v = Matrix<Float>([[0.0, 0.0, 0.0]])

let A = Matrix<Float>([[1.0, 0.2],[0.1, 1.4]])
let v: Matrix<Float> = Matrix([[0.0, 0.0]])

let gauss = MultivariateNormal(v, A)

let X = gauss.rvs(1000)

print(X[column: 0].mean())
print(X[column: 1].mean())
//print(X[column: 2].mean())

//print(gauss.pdf(randMatrix(10, 3)))


//print(mat ** 0.5)

//let N = 100
//let L = cholesky(A, "L")
//var Y: Matrix<Float> = zeros(N, 3)
//
//for n in 0..<N{
//    var X: [Float] = []
//    for i in 0..<3 {
//        let U = Randoms.randomFloat(0.0, 1.0)
//        let V = Randoms.randomFloat(0.0, 1.0)
//        //    print(U, V)
//        let x = sqrtf(-2 * log(U)) * cos(2.0 * Float.pi * V)
//        X.append(x)
//    }
//
//
//    let y = L * Matrix(3, 1, X)
//    Y[n] = y.grid
//}
//print(Y[column: 0].mean())
//print(Y[column: 1].mean())
//print(Y[column: 2].mean())


