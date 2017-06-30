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
    
    public var parametersData: [ScalarT]
    public var trainables: [String] = []
    public var lockedParams: [String] = []
    public var parametersIds: [String:[IndexType]]
    public var nFeatures: Int
    public var nDataPoints: Int
    public var XUpdateMask: [Bool] = []
    
    public var X: MatrixT {
        get {
            return MatrixT(nDataPoints, nFeatures, parametersData[parametersIds["X"]!])
        }
        set(val) {
            parametersData[parametersIds["X"]!] = val.grid
        }
    }
    public var variance: ScalarT {
        get {
            return exp(logVariance)
//            return log(1 + exp(logVariance))
        }
        set(val) {
            logVariance = exp(val)
//            logVariance = log(exp(val) - 1)
        }
    }
    
    public var lengthscale: ScalarT {
        get {
            return exp(logLengthscale)
//            return log(1 + exp(logLengthscale))
        }
        set(val) {
            logLengthscale = exp(val)
//            logLengthscale = log(exp(val) - 1)
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
    
    public var nDims: Int {
        get {
            return trainableIds.count
        }
    }
    
    required public init() {
        nFeatures = 0
        nDataPoints = 0

        parametersData = zeros(2)
        parametersIds = ["logVariance": [0], "logLengthscale": [1], "X": []]
        
        variance = 100.0
        lengthscale = 100.0
        X = MatrixT()
    }
    
    public convenience init(variance: ScalarT, lengthscale: ScalarT, X: MatrixT, trainables: [String] = ["logVariance"], capacity: Int = 10000) {
        self.init()
        self.trainables = trainables
        (nDataPoints, nFeatures) = X.shape
        
        parametersData = []
        parametersData.reserveCapacity(capacity)
        
        parametersIds["logVariance"] = [parametersData.count]
        parametersData.append(log(variance))
        
        parametersIds["logLengthscale"] = [parametersData.count]
        parametersData.append(log(lengthscale))
        
        parametersIds["X"] = arange(parametersData.count, parametersData.count + X.size, 1)
        parametersData.append(contentsOf: X.grid)
        
        self.X = X
    }
    
    public func initParams() -> MatrixT {
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
    
    public func gradientX(_ X: MatrixT, _ Y: MatrixT, _ dLdK: MatrixT) -> MatrixT {
        let r = scaledDist(X, Y)
        let (N, D) = X.shape
        let dLdr = dKdr(r: r) ∘ dLdK
        var tmp = dLdr ∘ invDist(r)
        
        // TODO: detect X == Y here, should use Y: MatrixT? in the future
        if X.rows == Y.rows {
            if all(diag(r) == 0) {
                tmp = tmp + tmp.t
            }
        }
//        tmp = tmp + tmp.t
        var grad: MatrixT = zeros(N ,D)
        for i in 0..<D {
            grad[forall, i] = reduce_sum(tmp ∘ cross_add(X[forall, i], -Y[forall, i]), axis: 1)
        }
        
        grad = grad / (lengthscale * lengthscale)
        return grad
    }
    
    public func gradient(_ X: MatrixT, _ Y: MatrixT, _ dLdK: MatrixT) -> MatrixT {
//        let (N, D) = X.shape
        var dGrid: [ScalarT] = []
        let r = scaledDist(X, Y)
        let Kr = K(r: r)
        let dLdr = dKdr(r: r) ∘ dLdK
        
        // variance
        if trainables.contains("logVariance") {
            dGrid.append((reduce_sum(Kr ∘ dLdK))[0, 0] / variance)
        }
        
        // lengthscale
        if trainables.contains("logLengthscale") {
//            dGrid.append(-(reduce_sum((dLdK ∘ Kr) ∘ (r ∘ r) ))[0,0] / lengthscale) // 0.5 *
            dGrid.append(-reduce_sum(dLdr ∘ r)[0,0] / lengthscale)
        }
        
        // gradient wrt X
        if trainables.contains("X") {
            let xGrad = gradientX(X, Y, dLdK)
            dGrid.append(contentsOf: xGrad.grid)
//            var tmp = dLdr ∘ invDist(r)
//            tmp = tmp + tmp.t
//            var grad: MatrixT = zeros(N ,D)
//            for i in 0..<D {
//                grad[forall, i] = reduce_sum(tmp ∘ cross_add(X[forall, i], -Y[forall, i]), 1)
//            }
//            
//            grad = grad / (lengthscale * lengthscale)
//            dGrid.append(contentsOf: grad.grid)
        }
        return MatrixT([dGrid])
    }
     
    public func dist(_ X: MatrixT, _ Y: MatrixT) -> MatrixT {
        let xx = reduce_sum(X ∘ X, axis: 1)
        let yy = reduce_sum(Y ∘ Y, axis: 1)
        var dist = cross_add(xx, yy) - 2.0 * (X * Y′)
        
        if X.rows == Y.rows {
            // detects X == Y, should use Y: MatrixT? instead
            if diag(dist).sum()[0,0] < 1e-4 {
                for r in 0..<dist.rows {
                    dist[r, r] = 0.0
                }
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
                else {
                    dist[r, c] = 1.0 / dist[r, c]
                }
            }
        }
        return dist
    }
}

