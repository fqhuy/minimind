//: Playground - noun: a place where people can play

import Foundation
import Surge
import minimind

// random matrix
let m: Matrix<Float> = randMatrix(3, 3)
let a = Matrix<Float>([[1.2, 0.2, 0.3],
                       [0.5, 1.5, 0.2],
                       [0.1, 0.2, 2.0]])

let subM = m[0∷2, 0∷2] // matrix slicing
let cmean = m.mean(0) // mean across columns

let b = (m * a + a) ∘ m.t // linear math
//
//let (u, s, v) = svd(a) // Singular values & vectors
//let l = cholesky(a, "L") // Cholesky & LDLT
//let (evals, evecs) = eigh(a, "L") // Eigen decom.

let i = Matrix<Float>([[1.0, 0.0],[0.0, 1.0]])
let X = i ⊗ a

print(X)

let v1 = [1.0, 2.0 ]
let v2 = [2.0, 3.0]

v1 * v2
