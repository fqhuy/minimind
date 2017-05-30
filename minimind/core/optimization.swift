//
//  optimization.swift
//  minimind
//
//  Created by Phan Quoc Huy on 5/28/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation
import Surge

public protocol ObjectiveFunction {
    associatedtype ScalarT
    associatedtype MatrixT
    func compute(_ x: MatrixT) -> ScalarT
    func gradient(_ x: MatrixT) -> MatrixT
}

class AnyObjectiveFunction<S>: ObjectiveFunction where S: ExpressibleByFloatLiteral & FloatingPoint {
    typealias ScalarT = S
    typealias MatrixT = Matrix<S>
    
    func compute(_ x: MatrixT) -> ScalarT {
        return 0.0
    }
    
    func gradient(_ x: MatrixT) -> MatrixT {
        return MatrixT([[]])
    }
}


public protocol Optimizer {
    associatedtype ScalarT
    associatedtype MatrixT
    func optimize(verbose: Bool) -> (MatrixT, [Float], Int)
    func get_cost() -> Double
}
