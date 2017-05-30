//
//  gaussian_process.swift
//  minimind
//
//  Created by Phan Quoc Huy on 3/14/16.
//  Copyright © 2016 Phan Quoc Huy. All rights reserved.
//

import Foundation
import Surge

public protocol GaussianProcess: BaseEstimator, RegressorMixin {
    associatedtype KernelT: Kernel
    associatedtype ScalarT = KernelT.ScalarT
    associatedtype MatrixT = KernelT.MatrixT
    
    var kernel: KernelT {get set}

    func fit(X: MatrixT, y: MatrixT)
    
    func score(X: MatrixT, y: MatrixT) -> ScalarT
    
    func predict(X: MatrixT) -> MatrixT
}

class GaussianProcessRegressor<T, K: Kernel >: GaussianProcess where T: ExpressibleByFloatLiteral & FloatingPoint, K.MatrixT == Matrix<T>, K.ScalarT == T {
    var kernel: K
    var Kxx: MatrixT
    var noiseModel: String
    var X: MatrixT
    var noise: MatrixT
    var y: MatrixT
    
    typealias KernelT = K
    typealias ScalarT = T
    typealias MatrixT = Matrix<T>
    
    public init(noiseModel: String = "Spherical") {
        kernel = KernelT()
        Kxx = MatrixT()
        X = MatrixT()
        noise = MatrixT()
        y = MatrixT()
        self.noiseModel = noiseModel
    }
    
    func predict(X: MatrixT) -> MatrixT {
        let Kxz = kernel.K(self.X, X)!
        return Kxz * (Kxx + noise) * y
    }

    func score(X: MatrixT, y: MatrixT) -> ScalarT {
        return 0.0
    }

    func fit(X: MatrixT, y: MatrixT) {
        Kxx = self.kernel.K(X, X)!
    }


}
