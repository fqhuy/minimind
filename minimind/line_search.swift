//
//  line_search.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/19/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation

public protocol LineSearchOptimizer: Optimizer {
    var currentPosition: MatrixT {get set}
    var currentSearchDirection: MatrixT {get set}
    var c1: ScalarT {get set}
    var c2: ScalarT {get set}
    var stepLength: ScalarT {get set}

    
    func checkSufficientDecrease(stepLength: ScalarT) -> Bool
    func checkCurvatureCondition(stepLength: ScalarT) -> Bool
    func interpolateStepLength(stepLength: ScalarT) -> ScalarT
}

public extension LineSearchOptimizer where ObjectiveFunctionT.ScalarT == ScalarT {
    func phi(_ stepLength: ScalarT) -> ScalarT {
        return objective.compute(currentPosition + stepLength * currentSearchDirection)
    }
    
    func dPhi(_ stepLength: ScalarT = 0.0) -> ScalarT {
        return (objective.gradient(currentPosition + stepLength * currentSearchDirection) * currentSearchDirection.t)[0,0]
    }
    
    func cubicInterpolate(_ alphaLo: ScalarT, _ alphaHi: ScalarT) -> ScalarT {
        let A = MatrixT([[pow(alphaHi, 2), -pow(alphaLo, 2)],[-pow(alphaHi, 3), pow(alphaLo, 3)]])
        let v = MatrixT([[phi(alphaLo) - phi(0) - dPhi(0) * alphaLo, phi(alphaHi) - phi(0) - dPhi(0) * alphaHi]])
        let c = 1.0 / (pow(alphaHi, 2) * pow(alphaLo, 2) * (alphaLo - alphaHi))
        let ab = c * A * v.t
        let (a, b) = tuple(ab.grid)
        
        let nom = -b * sqrt(b * b - 3 * a * dPhi(0))
        return nom / (3.0 * a)
    }
    
    func quadraticInterpolate(_ alphaLo: ScalarT, _ alphaHi: ScalarT) -> ScalarT {
        let nom = (dPhi(alphaLo) * alphaHi * alphaHi)
        let denom = (2.0 * phi(alphaHi) - phi(alphaLo) - dPhi(alphaLo) * alphaHi )
        return nom / denom
    }
    
    func interpolateStepLength(stepLength: ScalarT = 1.0) -> ScalarT {
        func checkAlpha(_ anew: ScalarT, _ aold: ScalarT) -> ScalarT {
            var re = anew
            //TODO: Magic numbers here
            if (abs(anew - aold) < 1e-5) || (anew < aold - 0.8 * aold) {
                re = aold / 2.0
            }
            return re
        }
        
        
        var alpha0 = stepLength
        if checkSufficientDecrease(stepLength: alpha0) {
            return alpha0
        }
        alpha0 = checkAlpha(alpha0, 0.0)
        
        // quadratic interpolant
        var alpha1 = quadraticInterpolate(0.0, alpha0)
        if checkSufficientDecrease(stepLength: alpha1) {
            return alpha1
        }
        alpha1 = checkAlpha(alpha1, alpha0)
        
        var trial = 0
        while trial < 100 {
            // cubic interpolant
            let alpha2 = cubicInterpolate(alpha1, alpha0)
            if checkSufficientDecrease(stepLength: alpha2) {
                return alpha2
            }
            // reset alpha low and alpha high and repeat
            alpha0 = alpha1
            alpha1 = checkAlpha(alpha2, alpha1)
            
            trial += 1
        }
        return stepLength
    }
    
    func checkSufficientDecrease(stepLength: ScalarT) -> Bool {
        let x = currentPosition
        let p = currentSearchDirection
        return objective.compute(x + stepLength * p) <= objective.compute(x) + c1 * stepLength * (objective.gradient(x) * p.t)[0, 0]
    }
    
    func checkCurvatureCondition(stepLength: ScalarT) -> Bool {
        let x = currentPosition
        let p = currentSearchDirection
        return (objective.gradient(x + stepLength * p) * p.t)[0,0] >= c2 * (objective.gradient(x) * p.t)[0, 0]
    }
    
    func lineSearch() -> ScalarT {
        let alpha0: ScalarT = 0.0
        let alphaMax: ScalarT = 100
        var alpha: ScalarT = ScalarT(arc4random_uniform(100))
        var oldAlpha: ScalarT = alpha
        var i: Int = 0
        while i < 100 {
            let ø = phi(alpha)
            if (ø > phi(0) + c1 * alpha * dPhi()) || (phi(alpha) > phi(oldAlpha) && i > 1) {
                let alphaStar = zoom(alpha: alpha, oldAlpha: oldAlpha)
                return alphaStar
            }
            let π = dPhi(alpha)
            if abs(π) <= -c2 * dPhi(0) {
                return alpha
            }
            
            if π >= 0 {
                return zoom(alpha: alpha, oldAlpha: oldAlpha)
            }
            oldAlpha = alpha
            alpha = ScalarT(arc4random_uniform(100))
            i += 1
        }
        return alpha
    }
    
    func zoom(alpha: ScalarT, oldAlpha: ScalarT) -> ScalarT {
        var alphaLo: ScalarT = 0.0
        var alphaHi: ScalarT = 10.0
        var trial = 0
        while trial < 100 {
            let alpha = interpolateStepLength(stepLength: alphaLo)
            let ø = phi(alpha)
            if ø > phi(0) + c1 * alpha * dPhi(0) || ø >= phi(alphaLo) {
                alphaHi = alpha
            } else {
                let π = dPhi(alpha)
                if abs(π) <= -c2 * dPhi(0) {
                    return alpha
                }
                
                if π * (alphaHi - alphaLo) >= 0 {
                    alphaHi = alphaLo
                }
                
                alphaLo = alphaHi
            }
            trial += 1
        }
        return alpha
    }
}

public class NewtonOptimizer<F: ObjectiveFunction>: LineSearchOptimizer where F.ScalarT == Float {
    public typealias ObjectiveFunctionT = F
    public typealias ScalarT = Float
    
    public var stepLength: Float = 1.0
    public var currentPosition: Matrix<Float>
    public var currentSearchDirection: Matrix<Float>
    public var maxIters = 100
    public var initX: Matrix<Float>
    public var objective: F
    public var Xs: [Matrix<Float>] = []
    public var c1: Float = 0.0001
    public var c2: Float = 0.0001
    
    public init(objective: F, stepLength: ScalarT, initX: Matrix<Float>, maxIters: Int) {
        self.stepLength = stepLength
        self.currentSearchDirection = Matrix<Float>()
        self.currentPosition = initX
        self.initX = initX
        self.maxIters = maxIters
        self.objective = objective
    }
    
    public func optimize(verbose: Bool) -> (Matrix<Float>, [Float], Int) {
        var currentX = initX
        var iter = 0
        var currentF: Float = 0.0
        var Fs: [Float] = []
        
        while iter < maxIters {
            Xs.append(currentX)
            currentF = objective.compute(currentX)
            Fs.append(currentF)
            let H = objective.hessian(currentX)
//            let L = cholesky(H, "L")
            
            let G = objective.gradient(currentX)
            
            currentX = currentX - stepLength * transpose(inv(H) * G.t) // * G  //
            iter += 1
            
            if verbose {
                print("iter: ", iter, ", f: ", currentF)
            }
            
        }
        Xs.append(currentX)
        return (currentX, Fs, iter)
    }
    
    public func getCost() -> Double {
        return 0.0
    }

}
