//
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
    
    public var likelihood: GPLikelihood<KernelT> {
        get {
            return GPLikelihood(kernel, noise, Xtrain, ytrain)
        }
        
        set(val) {
            
        }
    }

    public init( kernel: KernelT, alpha: ScalarT = 1.0) {
        self.kernel = kernel
        Kxx = MatrixT()
        Xtrain = MatrixT()
        noise = MatrixT()
        ytrain = MatrixT()
        self.alpha = alpha
    }
    
    public convenience init(X: MatrixT, Y: MatrixT, kernel: KernelT, alpha: ScalarT = 1.0) {
        self.init(kernel: kernel, alpha: alpha)
        self.Xtrain = X
        self.ytrain = Y
    }
    
    public func predict(_ X: MatrixT) -> (MatrixT, MatrixT) {
        let Kxz = kernel.K(X, Xtrain)
        let Kzz = kernel.K(X, X)
        Kxx = kernel.K(Xtrain, Xtrain)
        
        let invK = inv(Kxx + noise)
        let Sigma = Kzz - Kxz * invK * transpose(Kxz)
        let Mu = Kxz * invK * ytrain
        
        return (Mu.t, Sigma)
    }
    
    public func fit(_ X: MatrixT, _ y: MatrixT, maxiters: Int = 200, verbose: Bool = true) {
        Kxx = kernel.K(X, X)
        Xtrain = X
        ytrain = y
        
        let e: Matrix<ScalarT> = eye(X.rows)
        noise = e * (alpha * alpha)
        
        let llh = GPLikelihood(kernel, noise, Xtrain, ytrain)
        
        let scg = SCG(objective: llh, learning_rate: 0.01, init_x: kernel.init_params(), maxiters: maxiters)
        
        let (x, _, _) = scg.optimize(verbose: verbose)
        
        kernel.set_params(x)
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
        
        kernel.set_params(x)
        
        let C = kernel.K(Xtrain, Xtrain) + noise
        let N = Float(Xtrain.rows)
//        let D = Float(Xtrain.columns)
        
        let L = cholesky(C, "L")
//        let L = ldlt(C, "L")
//        let alpha = solve_triangular(L, ytrain, "L")
        let alpha = cho_solve(L, ytrain, "L")
        
        // same as 0.5 * tr(alpha.t * alpha)
        let ytCy = 0.5 * reduce_sum(alpha ∘ ytrain)[0, 0] //in neill code, it is alpha \circ alpha

        let logdetC = reduce_sum(log(diag(L)))[0, 0] // 0.5 * D * logdet(C)

        // Negative log likelihood
        return ytCy + logdetC + N / 2.0 * log(2.0 * ScalarT.pi) + kernel.log_prior
    }
    
    public func gradient(_ x: MatrixT) -> MatrixT {
//        let tmp = kernel.get_params()
        kernel.set_params(x)
        
        let C = kernel.K(Xtrain, Xtrain) + noise
//        let N = Xtrain.rows
        
//        direct way
        let Cinv = inv(C)
        let D = Float(Xtrain.columns)
        let dLdK = Cinv * ytrain * ytrain.t * Cinv + D * Cinv
        
        // Fast
//        let L = cholesky(C, "L")
////        let L = ldlt(C, "L")
////        let B = solve_triangular(L, solve_triangular(L.t, ytrain, "U"), "L")
//        let B = solve_triangular(L, solve_triangular(L.t, ytrain, "U"), "L")
//        
//        let D = ScalarT(Xtrain.columns)
//        
//        // WEIRD! BUT THIS IS HOW IT WORKS
//        let iL = inv(L, "U")
//        
//        // TODO: possibly wrong
//        let t1 = -(B * transpose(B) )
//        let t2 = D * (iL * transpose(iL) )
//        let dLdK = t1 + t2 // -(B * B.t) + D * (iL * iL.t)

//        let alpha = cholesky(C, "L")
//        var tmp = alpha * alpha.t
//        let dLdK = tmp - cho_solve(alpha, eye(N))
        
        return kernel.gradient(Xtrain, Xtrain, dLdK)
    }
}
