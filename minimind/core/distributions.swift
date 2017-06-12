//
//  distributions.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/3/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation
//import Surge

public protocol Distribution {
    associatedtype ScalarT: FloatType
    typealias MatrixT = Matrix<ScalarT>
    
    func rvs(_ size: Int) -> MatrixT
    
    func pdf(_ x: MatrixT) -> MatrixT
    
    func logpdf(_ x: MatrixT) -> MatrixT
}

public struct MultivariateNormal<T: FloatType>: Distribution {
    public typealias ScalarT = T
    public var mean: MatrixT
    public var cov: MatrixT
    public var shape: [Int]
    
    public init(_ mean: MatrixT, _ cov: MatrixT){
        self.mean = mean
        self.cov = cov
        self.shape = [mean.columns]
    }
    
    public func rvs(_ size: Int) -> MatrixT {
        fatalError("unimplemented")
    }
    
    public func pdf(_ x: MatrixT) -> MatrixT {
        fatalError("unimplemented")
    }
    
    public func logpdf(_ x: MatrixT) -> MatrixT {
        fatalError("unimplemented")
    }
}

extension MultivariateNormal where T == Float {
    
    // Box-muller and Cholesky method
    public func rvs(_ size: Int) -> MatrixT {
//        let L = cholesky(cov, "L")
        let L = ldlt(cov, "L")
        
        var Y: MatrixT = zeros(size, mean.size)
        var X: MatrixT = zeros(mean.size, 1)
        let mu = mean.t
        for n in 0..<size{
            for i in 0..<mean.size {
                let U = Randoms.randomFloat(0.0, 1.0)
                let V = Randoms.randomFloat(0.0, 1.0)
                //    print(U, V)
                let x = sqrtf(-2 * log(U)) * cos(2.0 * Float.pi * V)
                X[i, 0] = x
            }

            let y = L * X + mu
            Y[n] = y
        }        
        return Y
    }
    
// EIGEN METHOD
//    public func rvs(_ size: Int) -> MatrixT {
//        let (evals, eivecs) = eigh(cov, "L")
//        let A = eivecs
//        let D: MatrixT = sqrt(diagonal(evals.grid))
//        let Q = D * A
//        let mu = transpose(self.mean)
//        let N = 12
//        
//        var X: MatrixT = zeros(size, mean.size)
//        
//        for j in 0..<size{
//            var x: MatrixT = zeros(1, mean.size)
//            for i in 0..<mean.size {
//                let v: [Float] = randArray(n: N)
//                let xi =  sum(v) - 6.0
//                x[0, i] = xi
//            }
//            
//            let y = Q * transpose(x) + mu
//            X[j] = y.grid
//        }
//        return X
//
//    }
    
    public func pdf(_ x: MatrixT) -> MatrixT {
        let invCov = inv(cov)
        let r = x - mean
        let D = T(mean.size)
        return Float(1.0) / sqrt(pow(2.0 * T.pi, D) * det(cov)) * diag(exp(-0.5 * r * invCov * r.t ))
    }
    
    public func logpdf(_ x: MatrixT) -> MatrixT {
        return log(pdf(x))
    }
}
