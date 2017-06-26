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
    /// constant for Wolfe sufficient decrease condiion
    var c1: ScalarT {get set}
    /// constant for Wolfe curvature condition
    var c2: ScalarT {get set}
    var stepLength: ScalarT {get set}
    var nStepLengthTrials: Int {get set}
    var fTol: ScalarT {get set}

    
    func checkSufficientDecrease(alpha: ScalarT) -> Bool
    func checkCurvatureCondition(alpha: ScalarT) -> Bool
    func interpolateStepLength(alpha: ScalarT) -> ScalarT
}

//MARK: Extension and subclass needs the same constraint to work correctly!!

public extension LineSearchOptimizer where ObjectiveFunctionT.ScalarT == Float {

    /// objective w.r.t stepLength
    func phi(_ alpha: ScalarT) -> ScalarT {
        return objective.compute(currentPosition + alpha * currentSearchDirection)
    }
    
    /// derivative of objective w.r.t stepLength
    func dPhi(_ alpha: ScalarT = 0.0) -> ScalarT {
        return (objective.gradient(currentPosition + alpha * currentSearchDirection) * currentSearchDirection.t)[0,0]
    }
    
    /// Wolfe condition 1
    func checkSufficientDecrease(alpha: ScalarT) -> Bool {
        return phi(alpha) <= phi(0.0) + c1 * alpha * dPhi(0)
    }
    
    /// Wolfe condition 2
    func checkCurvatureCondition(alpha: ScalarT) -> Bool {
        return dPhi(alpha) >= c2 * dPhi(0)
    }
    
    /// strong Wolfe condition 2
    func checkStrongCurvatureCondition(alpha: ScalarT) -> Bool {
        return abs(dPhi(alpha)) <= abs(c2 * dPhi(0))
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
        return -nom / denom
    }
    
    func checkAlpha(_ anew: ScalarT, _ aold: ScalarT) -> ScalarT {
        var re = anew
        //TODO: Magic numbers here
        if (abs(anew - aold) < 1e-5) || (anew < aold / 2.0) {
            re = aold / 2.0
        }
        return re
    }
    
    func interpolateStepLength(alpha: ScalarT = 1.0) -> ScalarT {
        var alpha0 = alpha
        if checkSufficientDecrease(alpha: alpha0) {
            return alpha0
        }
        alpha0 = checkAlpha(0.0, alpha0)
        
        // quadratic interpolant
        var alpha1 = quadraticInterpolate(0.0, alpha0)
        if checkSufficientDecrease(alpha: alpha1) {
            return alpha1
        }
        alpha1 = checkAlpha(alpha1, alpha0)
        
        var i = 0
        while i < nStepLengthTrials {
            // cubic interpolant
            let alpha2 = cubicInterpolate(alpha1, alpha0)
            if checkSufficientDecrease(alpha: alpha2) {
                return alpha2
            }
            // reset alpha low and alpha high and repeat
            alpha0 = alpha1
            alpha1 = checkAlpha(alpha2, alpha1)
            
            i += 1
        }
        return alpha
    }
    
    public func backTrackingSearch(_ initAlpha: ScalarT = 1.0) -> ScalarT {
        let rho: ScalarT = 0.9
        var i = 0
        var alpha = initAlpha
        while i < nStepLengthTrials {
            //if  phi(alpha) <= phi(0) + c * alpha * dPhi(0)  {
            if checkSufficientDecrease(alpha: alpha) {
                break
            }
            
            let oldAlpha = alpha
            alpha = rho * alpha
            
            alpha = checkAlpha(alpha, oldAlpha)
            i += 1
        }
        return alpha
    }
    
    /// compute a reasonable stepLength based on current position & gradient
    public func lineSearch(_ alphaMax: ScalarT = 1.0) -> ScalarT {
        let alpha0: ScalarT = 0.0
        var alpha: ScalarT = interpolateStepLength(alpha: alphaMax)
        var oldAlpha: ScalarT = alpha0
        var i: Int = 1
        while i < nStepLengthTrials {
            let ø = phi(alpha)
            // decrease condition
            if (ø > phi(0) + c1 * alpha * dPhi(0)) || (phi(alpha) >= phi(oldAlpha) && i > 1) {
                return zoom(alphaLo: oldAlpha, alphaHi: alpha)
            }
            let π = dPhi(alpha)
            // strong curvature condition
            if abs(π) <= -c2 * dPhi(0) {
                return alpha
            }
            
            if π >= 0 {
                return zoom(alphaLo: alpha, alphaHi: oldAlpha)
            }
            oldAlpha = alpha
            
            // N.O book says we can either do this or use interpolateStepLength.
            alpha += (alphaMax - alpha) * 0.25
            // alpha = interpolateStepLength(stepLength: alpha)
            i += 1
        }
        return alpha
    }
    
    public func zoom(alphaLo: ScalarT, alphaHi: ScalarT) -> ScalarT {
//        precondition(alphaLo < alphaHi)
        var alphaL = alphaLo
        var alphaH = alphaHi
        var i = 0
        var alpha = alphaH
        while i < nStepLengthTrials {
            // quadraticInterpolate(min(alphaLo, alphaHi), max(alphaLo, alphaHi))
            // cubicInterpolate(min(alphaLo, alphaHi), max(alphaLo, alphaHi))
            // interpolateStepLength(alpha: min(alphaLo, alphaHi))
            alpha = quadraticInterpolate(min(alphaLo, alphaHi), max(alphaLo, alphaHi))
            let ø = phi(alpha)
            if ø > phi(0) + c1 * alpha * dPhi(0) || ø >= phi(alphaL) {
                alphaH = alpha
            } else {
                let π = dPhi(alpha)
                if abs(π) <= -c2 * dPhi(0) {
                    return alpha
                }
                
                if π * (alphaHi - alphaLo) >= 0 {
                    alphaH = alphaL
                }
                
                alphaL = alpha
            }
            i += 1
        }
        return alpha
    }
}

public class NewtonOptimizer<F: ObjectiveFunction>: LineSearchOptimizer where F.ScalarT == Float {
    public typealias ObjectiveFunctionT = F
    public typealias ScalarT = Float
    
    public var stepLength: Float = 1.0
    public var initStepLength: Float = 1.0
    public var currentPosition: MatrixT
    public var currentSearchDirection: MatrixT
    public var maxIters = 100
    public var nStepLengthTrials = 100
    public var initX: MatrixT
    public var objective: F
    public var Xs: [MatrixT] = []
    // 0 < c1 < c2 < 1
    public var c1: ScalarT = 0.0001
    public var c2: ScalarT = 0.001
    public var fTol: Float = 1e-5
    
    public init(objective: F, stepLength: ScalarT, initX: MatrixT?, maxIters: Int, fTol: ScalarT = 1e-5) {
        self.stepLength = stepLength
        self.currentSearchDirection = Matrix()
        
        if initX == nil {
            self.initX = zeros(1, objective.dims)
        } else {
            self.initX = initX!
        }
        self.maxIters = maxIters
        self.objective = objective
        self.currentPosition = self.initX
        self.initStepLength = stepLength
        self.fTol = fTol
    }
    
    public func optimize(verbose: Bool) -> (MatrixT, [Float], Int) {
        currentPosition = initX
        var iter = 0
        var currentF: Float = 0.0
        var oldF: Float = 0.0
        var Fs: [Float] = []

        while iter < maxIters {
            Xs.append(currentPosition)
            oldF = currentF
            currentF = objective.compute(currentPosition)
            Fs.append(currentF)
            let H = objective.hessian(currentPosition)
            let L = cho_factor(H, uplo: "L")
            let G = objective.gradient(currentPosition)
            
            currentSearchDirection = -cho_solve(L, G, "L") // -transpose(inv(H) * G.t)
//            stepLength = backTrackingSearch(initStepLength)
            stepLength = lineSearch(1.0)
            
            currentPosition = currentPosition + stepLength * currentSearchDirection // * G  //
            iter += 1
            
            if verbose {
                print("iter: ", iter, ", f: ", currentF, ", alpha: ", stepLength)
            }
            
            if abs(oldF - currentF) < fTol {
                print("converged by relative function reduction!")
                break
            }
        }
        Xs.append(currentPosition)
        return (currentPosition, Fs, iter)
    }
    
    public func getCost() -> Double {
        return 0.0
    }

}

public class QuasiNewtonOptimizer<F: ObjectiveFunction>: NewtonOptimizer<F> where F.ScalarT == Float {
    public typealias ObjectiveFunctionT = F
    public typealias ScalarT = Float
    
    var H: MatrixT
    var gTol: ScalarT
    
    public init(objective: F, stepLength: ScalarT, initX: MatrixT?, initH: MatrixT?, gTol: ScalarT, maxIters: Int, fTol: ScalarT = 1e-5) {
        if initH == nil {
            H = eye(objective.dims)
        } else {
            H = initH!
        }
        self.gTol = gTol
        super.init(objective: objective, stepLength: stepLength, initX: initX, maxIters: maxIters, fTol: fTol)

    }
    
    public override func optimize(verbose: Bool) -> (MatrixT, [Float], Int) {
        var k = 0
        var g = objective.gradient(currentPosition)
        var oldG = g
        var oldPosition = currentPosition
        let I: MatrixT = eye(H.rows)
        var currentF: ScalarT = objective.compute(currentPosition)
        var oldF: ScalarT = currentF
 
        while norm(g, "F") > gTol || k < maxIters {
            currentSearchDirection = -transpose(H * g.t)
            stepLength = lineSearch(1.0)
            currentPosition = currentPosition + stepLength * currentSearchDirection
            
            oldF = currentF
            currentF = objective.compute(currentPosition)
            
            g = objective.gradient(currentPosition)
            let sk = currentPosition - oldPosition
            let yk = g - oldG
            
            let rhok = (1.0 / (yk * sk.t))[0, 0]
            
            //BFGS
            let v = (I - rhok * sk.t * yk)
            H = v * H * v.t + rhok * sk.t * sk
            
            if verbose == true {
                print("iter: ", k, ", f: ", currentF, ", alpha: ", stepLength)
            }
            
            if abs(oldF - currentF) < fTol {
                print("converged by relative function reduction!")
                break
            }
            
            oldG = g
            oldPosition = currentPosition
            k += 1
        }
        
        return (currentPosition, [0.0], k)
    }
}


