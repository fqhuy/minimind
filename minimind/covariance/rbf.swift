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
    
    public var n_dims: Int {
        get {
            return 2
        }
    }
    
    public var variance: ScalarT
    public var lengthscale: ScalarT
    public var X: MatrixT
    
    public var log_variance: ScalarT {
        get {
            return log(variance)
        }
        set(val) {
            variance = exp(val)
        }
    }
    
    public var log_lengthscale: ScalarT {
        get {
            return log(lengthscale)
        }
        set(val) {
            lengthscale = exp(val)
        }
    }
    
    public var log_prior: ScalarT {
        get {
            return 0.5 * ( pow(log_variance, 2.0) + pow(log_lengthscale, 2.0) )
        }
    }
    
    required public init() {
        variance = 1.0
        lengthscale = 1.0
        X = MatrixT()
    }
    
    required public init(variance: ScalarT = 0.1, lengthscale: ScalarT = 0.1) {
        self.variance = variance
        self.lengthscale = lengthscale
        X = MatrixT()
    }
    
    public func set_params(_ params: MatrixT) {
        log_variance = max(params[0, 0], 1e-5)
        log_lengthscale = max(params[0, 1], 1e-5)
        
        X.grid = params[0, 2∶].grid
//        log_lengthscale = params[0, 0]
    }
    
    public func get_params() -> MatrixT {
//        return MatrixT([[log_variance, log_lengthscale]])
        return MatrixT([[log_variance, log_lengthscale] ∪ X.grid ])

    }
    
    public func init_params() -> MatrixT {
        return MatrixT([[log_variance, log_lengthscale] ∪ X.grid])
//        return MatrixT([[log_lengthscale]])
    }
    
    public func K(_ X: MatrixT,_ Y: MatrixT) -> MatrixT {
        let dist = scaledDist(X, Y)
        let Kxx = K(r: dist)
        return Kxx
    }
    
    public func K(r: MatrixT) -> MatrixT {
        return variance * exp((-0.5 * (r ** 2.0)))
    }
    
    func dKdr(r: MatrixT) -> MatrixT {
        return -r ∘ K(r: r)
    }
    
    public func gradient(_ X: MatrixT, _ Y: MatrixT, _ dLdK: MatrixT) -> MatrixT {
//        var d: MatrixT = zeros(1, 2)
        let (N, D) = X.shape
        var d: MatrixT = zeros(1, 2 + D * N)
        let r = scaledDist(X, Y)
        let Kr = K(r: r)
        let dLdr = dKdr(r: r) ∘ dLdK
        
        d[0, 0] = (reduce_sum(Kr ∘ dLdK))[0, 0] / variance
        d[0, 1] = -0.5 * (reduce_sum((dLdK ∘ Kr) ∘ (r ∘ r) ))[0,0]
        
        // gradient wrt X
        var tmp = dLdr ∘ invDist(r)
        tmp = tmp + tmp.t
        var grad: MatrixT = zeros(N ,D)
        for i in 0..<D {
            grad[forall, i] = reduce_sum(tmp ∘ cross_add(X[forall, i], -Y[forall, i]), 1)
        }
        
        d[0, 2∶] = grad
        
        return d
    }
    
    public func dist(_ X: MatrixT, _ Y: MatrixT) -> MatrixT {
        let xx = reduce_sum(X ∘ X, 1)
        let yy = reduce_sum(Y ∘ Y, 1)
        var dist = cross_add(xx, yy) - 2.0 * (X * Y′)
        
        if X.rows == Y.rows {
            for r in 0..<dist.rows {
                dist[r, r] = 0.0
            }
        }
        dist = clip(dist, 0.0, 1e10)
        return sqrt(dist)
    }
    
    public func scaledDist(_ X: MatrixT, _ Y: MatrixT) -> MatrixT {
        return dist(X, Y) / lengthscale
    }
    
    private func invDist(_ X: MatrixT, _ Y: MatrixT) -> MatrixT {
        let dist = scaledDist(X, Y)
        return invDist(dist)
    }
    
    private func invDist(_ r: MatrixT) -> MatrixT {
        var dist = r
        for r in 0..<dist.rows {
            for c in 0..<dist.columns {
                if dist[r, c] == 0 {
                    dist[r, c] = 1e10
                }
            }
        }
        return dist
    }
}

