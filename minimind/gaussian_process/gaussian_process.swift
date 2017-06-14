//
//  gaussian_process.swift
//  minimind
//
//  Created by Phan Quoc Huy on 3/14/16.
//  Copyright © 2016 Phan Quoc Huy. All rights reserved.
//

import Foundation
//import Surge

public protocol GaussianProcess: BaseEstimator, RegressorMixin {
    associatedtype KernelT: Kernel
    associatedtype ScalarT = KernelT.ScalarT
    associatedtype MatrixT = KernelT.MatrixT
    
    var kernel: KernelT {get set}

    func fit(X: MatrixT, y: MatrixT, maxiters: Int, verbose: Bool)
    
    func score(X: MatrixT, y: MatrixT) -> ScalarT
    
    func predict(X: MatrixT) -> (MatrixT, MatrixT) 
}

public class GaussianProcessRegressor<T: ScalarType, K: Kernel >: GaussianProcess where T: ExpressibleByFloatLiteral & FloatingPoint, K.MatrixT == Matrix<T>, K.ScalarT == T {
    public var kernel: K
    public var Kxx: MatrixT
    public var alpha: T
    public var Xtrain: MatrixT
    var noise: MatrixT
    public var ytrain: MatrixT
    
    public typealias KernelT = K
    public typealias ScalarT = T
    public typealias MatrixT = Matrix<T>
    
    public init( kernel: KernelT, alpha: T = 1.0) {
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

    public func fit(X: MatrixT, y: MatrixT, maxiters: Int = 200, verbose: Bool = true) {
        fatalError("unimplemented")
    }
}

public extension GaussianProcessRegressor where T == Float {
    public var likelihood: GPLikelihood<KernelT> {
        get {
            return GPLikelihood(kernel, noise, Xtrain, ytrain)
        }
        
        set(val) {
            
        }
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
        
        let e: Matrix<T> = eye(X.rows)
        noise = e * (alpha * alpha)
        
        let llh = GPLikelihood(kernel, noise, Xtrain, ytrain)
        
        let scg = SCG(objective: llh, learning_rate: 0.01, init_x: kernel.init_params(), maxiters: maxiters)
        
        let (x, _, _) = scg.optimize(verbose: verbose)
        
        kernel.set_params(x)
    }
}


public class GPLikelihood<K: Kernel>: ObjectiveFunction where K.MatrixT == Matrix<Float>, K.ScalarT == Float  {
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
