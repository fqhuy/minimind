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
}

extension Kernel where ScalarT: ExpressibleByFloatLiteral & FloatingPoint {
    
    func K(_ X: Matrix<ScalarT>, _ Y: Matrix<ScalarT>) -> Matrix<ScalarT> {
        return Surge.Matrix(rows: 1, columns: 1, repeatedValue: 0.0)
    }
}

public class RBF: Kernel {
    public typealias ScalarT = Float
    public typealias MatrixT = Matrix<ScalarT>
    
    public var alpha: ScalarT
    public var gamma: ScalarT
    var _K_xx: MatrixT
    
    required public init() {
        self.alpha = 0.0
        self.gamma = 0.0
        self._K_xx = MatrixT()
    }
    
    required public init(alpha: ScalarT = 0.1, gamma: ScalarT = 0.1) {
        self.alpha = alpha
        self.gamma = gamma
        self._K_xx = MatrixT()
    }
    
    public func K(_ X: MatrixT,_ Y: MatrixT) -> MatrixT {
        let xx = 0.5 * self.gamma * reduce_sum(X • X, 1)!
        let yy = 0.5 * self.gamma * reduce_sum(Y • Y, 1)!
        let dist = cross_add(xx, yy) - self.gamma * (X * Y′)
        return self.alpha * exp(-dist)
    }
}
