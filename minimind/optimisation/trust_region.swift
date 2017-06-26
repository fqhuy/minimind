//
//  trust_region.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/23/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation

public protocol TrustRegionOptimizer: Optimizer {
    /// B_k in N.O
    var hessianApproximate: MatrixT {get set}
    
    /// x_k
    var currentPosition: MatrixT {get set}
    
    /// p_k in N.O
    var currentSearchDirection: MatrixT {get set}
    
    // trust region radius
    var currentDelta: ScalarT {get set}
    
    /// ∆
    var deltaHat: ScalarT {get set}
    
    /// rho
    var eta: ScalarT {get set}
    
    func computeCauchyPoint() -> MatrixT
    func trustRegionSearch(_ delta0: ScalarT) -> MatrixT
    func approximateSearchDirection() -> MatrixT
    func quadraticApproximation(_ position: MatrixT) -> ScalarT
}

extension TrustRegionOptimizer {
    func computeRho() -> ScalarT {
        let nom = objective.compute(currentPosition) - objective.compute(currentPosition + currentSearchDirection)
        let denom = quadraticApproximation(zeros_like(currentPosition)) - quadraticApproximation(currentSearchDirection)
        return nom / denom
    }
    
    public func trustRegionSearch(_ Delta0: ScalarT) -> MatrixT {
//        var Delta: ScalarT = Delta0
        for k in 0..<100 {
            let pk = approximateSearchDirection()
            let rho = computeRho()
            
            if rho < 0.25 {
                currentDelta = 0.25 * currentDelta
            } else {
                if rho > 0.75 && norm(currentSearchDirection) == currentDelta {
                    currentDelta = min(2 * currentDelta, deltaHat)
                }
            }
            
            if rho > eta {
                currentPosition = currentPosition + currentSearchDirection
            }
        }
        return currentPosition
    }
    
    public func computeCauchyPoint() -> MatrixT {
        let gk = objective.gradient(currentPosition)
        let Bk = hessianApproximate
        let normgk = norm(gk)
        let psk = -currentDelta / normgk * gk
        
        let a = (gk * Bk * gk.t)[0,0]
        var tauk: ScalarT = 1.0
        if a > 0 {
            let b = pow(normgk, 3) / (currentDelta * a)
            tauk = min(b, 1.0)
        }
        return tauk * psk
    }

}

extension TrustRegionOptimizer where ObjectiveFunctionT.ScalarT == Float {
    /// iteratively solve subproblem
    public func approximateSearchDirection() -> MatrixT {
        var lamda: ScalarT = 0.1
        let I: MatrixT = eye(hessianApproximate.rows)
        let g = objective.gradient(currentPosition)
        
        for _ in 0..<5 {
            let R = cho_factor(hessianApproximate + lamda * I, "U")
            let pl = cho_solve(R, -g, "U")
            let ql = cho_solve(R.t, pl, "L")
            
            let npl = norm(pl)
            let nql = norm(ql)
            lamda = lamda + pow(npl / nql, 2) * ((npl - currentDelta) / currentDelta)
        }
        
        let R = cho_factor(hessianApproximate + lamda * I, "U")
        let p = cho_solve(R, -g)
        return p
    }
}


//public class DogLegOptimizer: TrustRegionOptimizer {
//
//
//    var hessianApproximate: MatrixT
//    var currentPosition: MatrixT
//    var currentSearchDirection: MatrixT
//    var currentDelta: ScalarT
//    var deltaHat: ScalarT
//    var eta: ScalarT
//    
//    public func optimize(verbose: Bool) {
//    
//    }
//    
//    public func approximateSearchDirection() -> MatrixT {
//        <#code#>
//    }
//}
