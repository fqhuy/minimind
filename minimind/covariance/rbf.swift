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
    
    public var X: MatrixT
    public var parametersData: [ScalarT]
    public var trainables: [String] = []
    public var parametersIds: [String:[IndexType]]
    
    
    public var variance: ScalarT {
        get {
            return exp(logVariance)
        }
        set(val) {
            logVariance = exp(val)
        }
    }
    
    public var lengthscale: ScalarT {
        get {
            return exp(logLengthscale)
        }
        set(val) {
            logLengthscale = exp(val)
        }
    }
    
    public var nDims: Int {
        get {
            return parametersIds.count
        }
    }
    
    public var logVariance: ScalarT {
        get {
            return parametersData[parametersIds["logVariance"]!][0]
        }
        set(val) {
            parametersData[parametersIds["logVariance"]!] = [val]
        }
    }
    
    public var logLengthscale: ScalarT {
        get {
            return parametersData[parametersIds["logLengthscale"]!][0]
        }
        set(val) {
            parametersData[parametersIds["logLengthscale"]!] = [val]
        }
    }
    
    public var logPrior: ScalarT {
        get {
            return 0.5 * ( pow(logVariance, 2.0) + pow(logLengthscale, 2.0) )
        }
    }
    
    required public init() {
        X = MatrixT()
        parametersData = zeros(n: 2)
        parametersIds = ["logVariance": [0], "logLengthscale": [1]]
        variance = 100.0
        lengthscale = 100.0
    }
    
    public convenience init(variance: ScalarT, lengthscale: ScalarT, X: MatrixT, trainables: [String] = ["variance"], capacity: Int = 10000) {
        self.init()
        self.trainables = trainables
        parametersData = []
        parametersData.reserveCapacity(capacity)
        
        parametersIds["logVariance"] = [parametersData.count]
        parametersData.append(variance)
        
        parametersIds["logLengthscale"] = [parametersData.count]
        parametersData.append(lengthscale)
        
        parametersIds["X"] = arange(parametersData.count, parametersData.count + X.size, 1)
        parametersData.append(contentsOf: X.grid)
        
        self.X = X
    }
    
    public func initParams() -> MatrixT {
//        return MatrixT([[logVariance, logLengthscale] ∪ self.X.grid])
        var params: [Float] = []
        for t in trainableIds {
            params.append(parametersData[t])
        }
        return MatrixT([params])
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
        let (N, D) = X.shape
        var d: MatrixT =  zeros(1, trainableIds.count) // zeros(1, 2 + D * N)
        let r = scaledDist(X, Y)
        let Kr = K(r: r)
        let dLdr = dKdr(r: r) ∘ dLdK
        
        // variance
        if trainables.contains("logVariance") {
            d[0, parametersIds["logVariance"]![0]] = (reduce_sum(Kr ∘ dLdK))[0, 0] / variance
        }
        
        // lengthscale
        if trainables.contains("logLengthscale") {
            d[0, parametersIds["logLengthscale"]![0]] = -0.5 * (reduce_sum((dLdK ∘ Kr) ∘ (r ∘ r) ))[0,0]
        }
        
        // gradient wrt X
        if trainables.contains("X") {
            var tmp = dLdr ∘ invDist(r)
            tmp = tmp + tmp.t
            var grad: MatrixT = zeros(N ,D)
            for i in 0..<D {
                grad[forall, i] = reduce_sum(tmp ∘ cross_add(X[forall, i], -Y[forall, i]), 1)
            }
        
            d[[0], parametersIds["X"]!] = grad.reshape([1, -1])
        }
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

