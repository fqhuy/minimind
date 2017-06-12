//
//  PCA.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/10/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation

class PCA: BaseEstimator {
    typealias ScalarT = Float
    typealias MatrixT = Matrix<Float>
    
    public var mean: MatrixT
    public var nComponents: Int
    public var components: MatrixT
    public var explained_variance: MatrixT
    
    public init(_ nComponents: Int) {
        self.nComponents = nComponents
        self.mean = MatrixT()
        self.components = MatrixT()
        self.explained_variance = MatrixT()
    }
    
    public func get_params() -> [String : Any] {
        return ["nComponents" : nComponents]
    }
    
    public func fit(_ X: MatrixT) {
        let (N, D) = X.shape
        let Xmean = X.mean(0)
        var S: MatrixT = zeros(D, D)
        
        for r in 0..<N {
            S += (X[r] - Xmean) * (X[r] - Xmean)′
        }
        
        S /= Float(N)
        let (evals, evecs) = eigh(S, "L")
        
        self.components = evecs[0∶D, 0∶nComponents].t
        self.explained_variance = evals[0, 0∶]
        self.mean = Xmean
        
    }
}
