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
    
    func predict(X: MatrixT) -> (MatrixT, MatrixT) 
}

public class GaussianProcessRegressor<T, K: Kernel >: GaussianProcess where T: ExpressibleByFloatLiteral & FloatingPoint, K.MatrixT == Matrix<T>, K.ScalarT == T {
    public var kernel: K
    public var Kxx: MatrixT
    public var alpha: T
    public var Xtrain: MatrixT
    var noise: MatrixT
    public var ytrain: MatrixT
    
    public typealias KernelT = K
    public typealias ScalarT = T
    public typealias MatrixT = Matrix<T>
    
    public init( kernel: KernelT, alpha: T = 1e-5) {
        self.kernel = kernel
        Kxx = MatrixT()
        Xtrain = MatrixT()
        noise = MatrixT()
        ytrain = MatrixT()
        self.alpha = alpha
    }
    
    public func predict(X: MatrixT) -> (MatrixT, MatrixT)  {
        fatalError("unimplemented")
    }

    public func score(X: MatrixT, y: MatrixT) -> ScalarT {
        fatalError("unimplemented")
    }

    public func fit(X: MatrixT, y: MatrixT) {
        fatalError("unimplemented")
    }
}

public extension GaussianProcessRegressor where T == Float {
    public var likelihood: GPLikelihood<T, KernelT> {
        get {
            return GPLikelihood(kernel, noise, Xtrain, ytrain)
        }
    }

    
    public func predict(_ X: MatrixT) -> (MatrixT, MatrixT) {
        let Kxz = kernel.K(X, Xtrain)
        let Kzz = kernel.K(X, X)
        let Sigma = Kzz - Kxz * inv(Kxx + noise) * transpose(Kxz)
        let Mu = Kxz * inv(Kxx + noise) * ytrain
        
        return (Mu, Sigma)
    }
    
    public func fit(_ X: MatrixT, _ y: MatrixT) {
        Kxx = kernel.K(X, X)
        Xtrain = X
        let e: Matrix<T> = eye(X.rows)
        noise = e * (alpha * alpha)
        ytrain = y
    }
}


public class GPLikelihood<T: FloatType, K: Kernel>: ObjectiveFunction where K.MatrixT == Matrix<T>, K.ScalarT == T  {
    public typealias ScalarT = T
    public typealias MatrixT = Matrix<ScalarT>
    public typealias KernelT = K
    

    public var kernel: KernelT
    public var noise: MatrixT
    public var Xtrain: MatrixT
    public var ytrain: MatrixT
    
    public init(_ kernel: KernelT, _ noise: MatrixT, _ X: MatrixT, _ y: MatrixT) {
        self.kernel = kernel
        self.noise = noise
        Xtrain = X
        ytrain = y
    }
    
    public func compute(_ x: MatrixT) -> ScalarT {
        fatalError("unimplemented")
    }
    
    public func gradient(_ x: MatrixT) -> MatrixT {
        fatalError("unimplemented")
    }
}


extension GPLikelihood where T == Float {
    public func compute(_ x: MatrixT) -> ScalarT {
        let C = kernel.K(x, x) + noise
        let N = Float(Xtrain.rows)
        let ytCy = (0.5 * ytrain.t * inv(C) * ytrain)[0, 0]
        let logdetC = 0.5 * logdet(C)
        
        // Negative log likelihood
        return ytCy + logdetC + N / 2 * log(2 * T.pi)
    }
    
    public func gradient(_ x: MatrixT) -> MatrixT {
        let C = kernel.K(x, x) + noise
        let Cinv = inv(C)
        let D = T(Xtrain.columns)
        let dLdK = Cinv * ytrain * ytrain.t * Cinv + D * Cinv
        
        return kernel.gradient(Xtrain, ytrain, dLdK)
    }
}
