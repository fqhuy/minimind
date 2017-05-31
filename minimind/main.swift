//
//  main.swift
//  minimind
//
//  Created by Phan Quoc Huy on 5/30/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation
import Surge
//import minimind

//public func -<T: ExpressibleByFloatLiteral & FloatingPoint>(lhs: Matrix<T>, rhs: T) -> Matrix<T> {
//    var newmat = lhs
//    newmat.grid = newmat.grid - rhs
//    return newmat
//}

var mat = zeros(4, 4)
var mat1 = ones(4, 4)

mat[0] = [1.0, 1.0, 1.0, 1.0]
let dia = diag(mat)
let diat = transpose(dia)

//let m1 = mat - 10.0
//
//var mat2 = mat - mat1

//print(mat2)
