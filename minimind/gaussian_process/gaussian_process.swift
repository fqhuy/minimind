
//  gaussian_process.swift
//  minimind
//
//  Created by Phan Quoc Huy on 3/14/16.
//  Copyright © 2016 Phan Quoc Huy. All rights reserved.
//

import Foundation
//import Surge

public protocol GaussianProcess: BaseEstimator {
    associatedtype KernelT: Kernel
    associatedtype ScalarT = KernelT.ScalarT
    
    var kernel: KernelT {get set}
    var alpha: ScalarT {get set}
    var noise: MatrixT {get}
    var Xtrain: MatrixT {get}
    var ytrain: MatrixT {get}
}

public class GaussianProcessRegressor<K: Kernel>: GaussianProcess, Regressor where K.ScalarT == Float {
    public typealias ScalarT = Float
    public typealias MatrixT = Matrix<ScalarT>
    public typealias KernelT = K

    public var kernel: K
    public var alpha: ScalarT
    public var Xtrain: MatrixT
    public var noise: MatrixT
    public var ytrain: MatrixT
    public var Kxx: MatrixT
    public var likelihood: GPLikelihood<KernelT>

    public init( kernel: KernelT, alpha: ScalarT = 1.0) {
        self.kernel = kernel
        self.alpha = alpha
        
        Kxx = MatrixT()
        Xtrain = MatrixT()
        noise = MatrixT()
        ytrain = MatrixT()
        likelihood = GPLikelihood(kernel, noise, Xtrain, ytrain)
    }
    
    public convenience init(X: MatrixT, Y: MatrixT, kernel: KernelT, alpha: ScalarT = 1.0) {
        self.init(kernel: kernel, alpha: alpha)
        self.Xtrain = X
        self.ytrain = Y
    }
    
    public func predict(_ X: MatrixT) -> (MatrixT, MatrixT) {
        // Last version: 7bd2556cf346844cedebe7590fce71ebc61cf189
        let Kxz = kernel.K(X, Xtrain)
        let Kzz = kernel.K(X, X)
        
        let Sigma = Kzz - Kxz * likelihood.woodburyInv * transpose(Kxz)
        let Mu = Kxz * likelihood.woodburyVector
        
        return (Mu, diag(Sigma))
    }
    
    public func fit(_ X: MatrixT, _ y: MatrixT, maxiters: Int = 200, verbose: Bool = true) {
        Kxx = kernel.K(X, X)
        Xtrain = X
        ytrain = y
        
        let e: Matrix<ScalarT> = eye(X.rows)
        noise = e * (alpha * alpha)
        
        likelihood = GPLikelihood(kernel, noise, Xtrain, ytrain)
        
//        let opt = SCG(objective: likelihood, learningRate: 0.01, initX: kernel.initParams(), maxIters: maxiters)
        let opt = QuasiNewtonOptimizer(objective: likelihood, stepLength: 1.0, initX: kernel.initParams(), initH: nil, gTol: 1e-8, maxIters: maxiters, alphaMax: 1.0, beta: 1.0)
//        let opt = SteepestDescentOptimizer(objective: likelihood, stepLength: 1.0, initX: kernel.initParams(), maxIters: maxiters, alphaMax: 2.0)
        let (x, _, _) = opt.optimize(verbose: verbose)
        kernel.setParams(x)
        Xtrain = kernel.X
        
        likelihood.update()
    }
    
    public func fit(X: Matrix<GaussianProcessRegressor.ScalarT>, Y: Matrix<GaussianProcessRegressor.ScalarT>) {
        self.fit(X, Y)
    }
    
    public func predict(Xstar: MatrixT) -> MatrixT {
        let (mu, _) = predict(Xstar)
        return mu
    }
    
    public func score(X: MatrixT, y: MatrixT) -> Float {
        fatalError("unimplemented")
    }
}


public class GPLikelihood<K: Kernel>: ObjectiveFunction where K.ScalarT == Float  {
    public typealias ScalarT = Float
    public typealias MatrixT = Matrix<ScalarT>
    public typealias KernelT = K
    
    public var dims: Int
    public var kernel: KernelT
    public var noise: MatrixT
    public var Xtrain: MatrixT
    public var ytrain: MatrixT
    
    // storing these for later prediction
    // "alpha"
    public var woodburyVector: MatrixT = MatrixT()
    // inv(C)
    public var woodburyInv: MatrixT = MatrixT()
    // L
    public var woodburyCho: MatrixT = MatrixT()
    // C
    public var C: MatrixT = MatrixT()
    
    public init(_ kernel: KernelT, _ noise: MatrixT, _ X: MatrixT, _ y: MatrixT) {
        self.kernel = kernel
        self.noise = noise
        dims = kernel.nDims
        Xtrain = X
        ytrain = y
    }
    
    public func update() {
        let K = kernel.K(Xtrain, Xtrain)
        
        C = K + noise
        let L = cho_factor(C, "L")
        let alpha = cho_solve(L, ytrain, "L")
        
        woodburyCho = L
        woodburyVector = alpha
        woodburyInv = cho_solve(L, eye(Xtrain.rows), "L")
    }
    
    public func compute(_ x: MatrixT) -> ScalarT {
        kernel.setParams(x)
        if kernel.trainables.contains("X") {
            Xtrain = kernel.X
        }
        let K = kernel.K(Xtrain, Xtrain)
        let C = K + noise
        let N = Float(Xtrain.rows)
        let D = Float(Xtrain.columns)
        
        let L = cho_factor(C, "L")
        let alpha = cho_solve(L, ytrain, "L")
        
        // same as 0.5 * tr(alpha.t * alpha)
        let ytCy = reduce_sum(alpha ∘ ytrain)[0, 0]

        let logdetC = D * reduce_sum(log(diag(L)))[0, 0] // 0.5 * D * logdet(C)

        // Negative log likelihood
        return 0.5 * (ytCy + logdetC + N * log(2.0 * ScalarT.pi)) + kernel.logPrior
    }
    
    public func gradient(_ x: MatrixT) -> MatrixT {
        kernel.setParams(x)
        if kernel.trainables.contains("X") {
            Xtrain = kernel.X
        }
        
        let C = kernel.K(Xtrain, Xtrain) + noise
        let D = Float(Xtrain.columns)
        let N = Xtrain.rows
        
//        DIRECT GRADIENT
//        let Cinv = inv(C)
//        let dLdK = Cinv * ytrain * ytrain.t * Cinv + D * Cinv

        // FASTEST
        // Ref: ExactGaussianInference from GPy and GaussianProcessRegressor from scikit-learn
        let L = cho_factor(C, "L")
        let alpha = cho_solve(L, ytrain, "L") // this gives inv(K) * ytrain
        let tmp =  alpha * alpha.t
        let dLdK = -0.5 * (tmp - D * cho_solve(L, eye(N), "L"))
        
        return kernel.gradient(Xtrain, Xtrain, dLdK)
    }
    
    public func hessian(_ x: Matrix<Float>) -> Matrix<Float> {
        return Matrix<Float>()
    }
}
