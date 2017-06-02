//
//  stationary.swift
//  minimind
//
//  Created by Phan Quoc Huy on 5/29/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation
import Surge

public protocol Kernel {
    associatedtype ScalarT
    associatedtype MatrixT
    
    init()
    
    func K(_ X: MatrixT, _ Y: MatrixT) -> MatrixT
    
    // return the gradient of K w.r.t all parameters
    func gradient(_ X: MatrixT, _ Y: MatrixT, _ dLdK: MatrixT) -> MatrixT
}

//extension Kernel where ScalarT: ExpressibleByFloatLiteral & FloatingPoint {
//    
//    func K(_ X: Matrix<ScalarT>, _ Y: Matrix<ScalarT>) -> Matrix<ScalarT> {
//        return Surge.Matrix(rows: 1, columns: 1, repeatedValue: 0.0)
//    }
//}


