//
//  pairwise.swift
//  minimind
//
//  Created by Phan Quoc Huy on 3/14/16.
//  Copyright © 2016 Phan Quoc Huy. All rights reserved.
//

import Foundation
import Surge

func euclidean_distances<T where T: FloatingPointType, T: FloatLiteralConvertible >() -> Matrix<T> {
    let mat = Matrix<T>(rows: 3, columns: 3, repeatedValue: 0.0)
    return mat
}

func rbf_kernel<T where T: FloatingPointType, T: FloatLiteralConvertible>() -> Matrix<T> {
    let mat = Matrix<T>(rows: 3, columns: 3, repeatedValue: 0.0)
    return mat
}
