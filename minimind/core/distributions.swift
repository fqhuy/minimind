//
//  distributions.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/3/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation
import Surge

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
    
    public func rvs(_ size: Int) -> MatrixT {
        let (evals, eivecs) = eigh(cov, "L")
        let A = eivecs
        let D: MatrixT = diagonal(clip(evals.grid, 0, 1e10))
        let Q = sqrt(D) * A
        let mu = transpose(self.mean)
        let N = 12
        
        var X: MatrixT = zeros(size, mean.size)
        
        for j in 0..<size{
            var x: MatrixT = zeros(1, mean.size)
            for i in 0..<mean.size {
                let v: [Float] = randArray(n: N)
                let xi = sum(v) - 6.0
                x[0, i] = xi
            }
            
            let y = Q * transpose(x) + mu // + transpose(mean)
            X[j] = y.grid
        }
        return X

    }
    
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
