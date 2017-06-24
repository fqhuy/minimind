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
    associatedtype ScalarT: FloatingPointScalarType
    typealias MatrixT = Matrix<ScalarT>
    func compute(_ x: MatrixT) -> ScalarT
    func gradient(_ x: MatrixT) -> MatrixT
    func hessian(_ x: MatrixT) -> MatrixT
}


public protocol Optimizer: class {
    associatedtype ObjectiveFunctionT: ObjectiveFunction
//    associatedtype ScalarT: FloatingPointScalarType
    typealias ScalarT = ObjectiveFunctionT.ScalarT
    typealias MatrixT = Matrix<ScalarT>
    
    var objective: ObjectiveFunctionT {get set}
    
    func optimize(verbose: Bool) -> (MatrixT, [Float], Int)
    func getCost() -> Double
}
