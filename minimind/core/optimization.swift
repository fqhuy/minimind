//
//  optimization.swift
//  minimind
//
//  Created by Phan Quoc Huy on 5/28/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation
//import Surge

public protocol ObjectiveFunction {
    associatedtype ScalarT: ScalarType
    typealias MatrixT = Matrix<ScalarT>
    
     func compute(_ x: MatrixT) -> ScalarT
     func gradient(_ x: MatrixT) -> MatrixT
}


public protocol Optimizer {
    associatedtype ScalarT: ScalarType
    typealias MatrixT = Matrix<ScalarT>
    
     func optimize(verbose: Bool) -> (MatrixT, [Float], Int)
     func get_cost() -> Double
}
