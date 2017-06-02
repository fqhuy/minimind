//
//  rbf.swift
//  minimind
//
//  Created by Phan Quoc Huy on 5/31/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation
import Surge


public class RBF: Kernel {
    public typealias ScalarT = Float
    public typealias MatrixT = Matrix<ScalarT>
    
    public var alpha: ScalarT
    public var gamma: ScalarT
    var _K_xx: MatrixT
    
    required public init() {
        self.alpha = 1.0
        self.gamma = 1.0
        self._K_xx = MatrixT()
    }
    
    required public init(alpha: ScalarT = 0.1, gamma: ScalarT = 0.1) {
        self.alpha = alpha
        self.gamma = gamma
        self._K_xx = MatrixT()
    }
    
    public func K(_ X: MatrixT,_ Y: MatrixT) -> MatrixT {
//        let xx = 0.5 * self.gamma * reduce_sum(X • X, 1)!
//        let yy = 0.5 * self.gamma * reduce_sum(Y • Y, 1)!
//        let dist = cross_add(xx, yy) - self.gamma * (X * Y′)
        let dist = self.dist(X, Y)
        return self.alpha * exp(-dist)
    }
    
    public func K(r: MatrixT) -> MatrixT {
        return alpha * exp(-r)
    }
    
    func dKdr(r: MatrixT) -> MatrixT {
        return -r * K(r: r)
    }
    
    public func gradient(_ X: MatrixT, _ Y: MatrixT, _ dLdK: MatrixT) -> MatrixT {
        var d: MatrixT = zeros(1, 2)
        let r = dist(X, Y)
        d[0, 0] = (reduce_sum(K(r: r) • dKdr(r: r), nil)! / alpha)[0, 0]
        d[0, 1] = -(reduce_sum((K(r: r) • dKdr(r: r)) • r, nil)! / gamma)[0, 0]
        return d
    }
    
    public func dist(_ X: MatrixT, _ Y: MatrixT) -> MatrixT {
        let xx = 0.5 * self.gamma * reduce_sum(X • X, 1)!
        let yy = 0.5 * self.gamma * reduce_sum(Y • Y, 1)!
        let dist = cross_add(xx, yy) - self.gamma * (X * Y′)
        return dist
    }
}
