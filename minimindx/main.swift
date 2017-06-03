//
//  main.swift
//  minimindx
//
//  Created by Phan Quoc Huy on 6/3/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation
import Surge
import minimind

print("Hello, World!")

let mat: Matrix<Float> = Matrix<Float>([[0.1, 0.4, 0.3],[0.2, 0.1, 0.1]]).t
let A: Matrix<Float> = mat * mat.t + eye(3)
let v = Matrix<Float>([[0.0, 0.0, 0.0]])

let gauss = MultivariateNormal(v, A)

print(gauss.rvs(10))
print(gauss.pdf(randMatrix(10, 3)))
