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
    var Kxx: MatrixT
    
    required public init() {
        self.alpha = 1.0
        self.gamma = 1.0
        self.Kxx = MatrixT()
    }
    
    required public init(alpha: ScalarT = 0.1, gamma: ScalarT = 0.1) {
        self.alpha = alpha
        self.gamma = gamma
        self.Kxx = MatrixT()
    }
    
    public func set_params(_ params: MatrixT) {
        alpha = params[0, 0]
        gamma = params[0, 1]
    }
    
    public func get_params() -> MatrixT {
        return MatrixT([[alpha, gamma]])
    }
    
    public func init_params() -> MatrixT {
        return MatrixT([[alpha, gamma]])
    }
    
    public func K(_ X: MatrixT,_ Y: MatrixT) -> MatrixT {
//        let xx = 0.5 * self.gamma * reduce_sum(X • X, 1)!
//        let yy = 0.5 * self.gamma * reduce_sum(Y • Y, 1)!
//        let dist = cross_add(xx, yy) - self.gamma * (X * Y′)
        let dist = self.dist(X, Y)
        Kxx = alpha * exp(-dist)
        return Kxx
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
        let Kr = K(r: r)
        let dKr = dKdr(r: r)
        d[0, 0] = (reduce_sum(Kr • dKr)! / alpha)[0, 0]
        d[0, 1] = -(reduce_sum((Kr • dKr) • r)! / gamma)[0, 0]
        return d
    }
    
    public func dist(_ X: MatrixT, _ Y: MatrixT) -> MatrixT {
        let xx = 0.5 * self.gamma * reduce_sum(X • X, 1)!
        let yy = 0.5 * self.gamma * reduce_sum(Y • Y, 1)!
        let dist = cross_add(xx, yy) - self.gamma * (X * Y′)
        return dist
    }
}
