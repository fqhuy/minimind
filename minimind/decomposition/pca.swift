//
//  PCA.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/10/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation

public class PCA: BaseEstimator {
    public typealias ScalarT = Float
    public typealias MatrixT = Matrix<Float>
    
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
        let XX = (X .- Xmean)
        
//        PRML, directly work on S
//        var S: MatrixT = zeros(D, D)
//        S = XX * XX′
//        S /= Float(N)
//        let (evals, evecs) = eigh(S, "L")
        
        // SVD(XX) ~ EIGH(S)
        let (u, evals, vt) = svd(XX, "S", "S")
        
        // Sign corrections
        let maxAbsVals = argmax(abs(u), 0)
        let signs = sign(diag(u[maxAbsVals.grid, 0∶D]))
//        let U = u .* signs
        let V = vt |* signs′
        
        self.components = V[0∶nComponents, 0∶D] // V[0∶D, 0∶nComponents].t
        self.explained_variance = (evals[0, 0∶] ∘ evals[0, 0∶]) / Float(N) // evals
        self.mean = Xmean
    }
    
    public func predict(_ Xstar: Matrix<Float>) -> Matrix<Float> {
        checkMatrices(components, Xstar, "cols=cols")
        return Xstar * self.components′
    }
}
