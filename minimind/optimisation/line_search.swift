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
    
//    func phi(alpha: ScalarT) -> ScalarT
//    func dPhi(alpha: ScalarT) -> ScalarT
    
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
    
    func checkAlpha(_ anew: ScalarT, _ aold: ScalarT) -> ScalarT {
        var re = anew
        //TODO: Magic numbers here
        if (abs(anew - aold) < 1e-5) || (anew < aold / 2.0){
            re = aold / 2.0
        }
        return re
    }
    
    //TODO: need to cache values here , _ fa: ScalarT, _ fb: ScalarT, _ fc: ScalarT, _ fpa: ScalarT
    func cubicInterpolate(_ a: ScalarT, _ b: ScalarT, _ c: ScalarT) -> ScalarT {

        let db = b - a
        let dc = c - a
        let A = MatrixT([[pow(dc, 2), -pow(db, 2)],[-pow(dc, 3), pow(db, 3)]])
        let v = MatrixT([[phi(b) - phi(a) - dPhi(a) * db, phi(c) - phi(a) - dPhi(a) * dc]])
        
        let C = 1.0 / (pow(dc, 2) * pow(db, 2) * (db - dc))
        let ab = C * A * v.t
        let (alpha, beta) = tuple(ab.grid)
        
        let R = beta * beta - 3 * alpha * dPhi(a)
        if R < 0 || alpha == 0 {
            return ScalarT.nan
        }
        
        let nom = -beta + sqrt(R)
        return a + nom / (3.0 * alpha)
    }
    
    func quadraticInterpolate(_ a: ScalarT, _ b: ScalarT) -> ScalarT {
        let d = b - a
        let denom = 2.0 * (phi(b) - phi(a) - dPhi(a) * d ) / (d * d)
        if denom <= 0 || a == b {
            return ScalarT.nan
        }
        return a - dPhi(a) / denom
    }
    
    func interpolateStepLength(alpha: ScalarT = 1.0) -> ScalarT {
        var alpha0 = alpha
        if checkSufficientDecrease(alpha: alpha0) {
            return alpha0
        }
//        alpha0 = checkAlpha(0.0, alpha0)
        
        // quadratic interpolant
        var alpha1 = quadraticInterpolate(0.0, alpha0)
        alpha1 = checkAlpha(alpha1, alpha0)
        if checkSufficientDecrease(alpha: alpha1) {
            return alpha1
        }
        
        var i = 0
        while i < nStepLengthTrials {
            // cubic interpolant
            var alpha2 = cubicInterpolate(0.0, alpha1, alpha0)
            alpha2 = checkAlpha(alpha2, alpha1)
            if checkSufficientDecrease(alpha: alpha2) {
                return alpha2
            }
            // reset alpha low and alpha high and repeat
            alpha0 = alpha1
            alpha1 = alpha2 // checkAlpha(alpha2, alpha1)
            
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
    public func lineSearch(_ alphaMax: ScalarT = 1.0, _ oldPhi0: ScalarT? = nil) -> ScalarT {
//        let alpha0: ScalarT = 0.0
        
        //TODO: could do better if we know phi from previous iteration
        var alpha: ScalarT = 1.0
        if oldPhi0 != nil {
            alpha = min(1.0, 1.01 * 2 * (phi(0) - oldPhi0!)/dPhi(0))
        }
        var oldAlpha: ScalarT = 0.0
        var i: Int = 1
        while i < nStepLengthTrials {
            if alpha == 0 {
                break
            }
            
            let ø = phi(alpha)
            // decrease condition
            if (ø > (phi(0) + c1 * alpha * dPhi(0))) || ((phi(alpha) >= phi(oldAlpha)) && (i > 1) ) {
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
//            alpha += (alphaMax - alpha) * 0.5
            alpha *= 2.0
            i += 1
        }
        
        return alpha
    }
    
    public func zoom(alphaLo: ScalarT, alphaHi: ScalarT) -> ScalarT {
        var alphaL = alphaLo
        var alphaH = alphaHi
        var alphaM: ScalarT = 0.0
        
//        var falphaL: ScalarT = 0.0
//        var falphaH: ScalarT = 0.0
//        var falphaM: ScalarT = 0.0
//        
//        var dfalphaL: ScalarT = 0.0
//        var dfalphaH: ScalarT = 0.0
//        var dfalphaM: ScalarT = 0.0
//        var falpha: ScalarT = 0.0
//        var dfalpha: ScalarT = 0.0
        
        var alpha = alphaH

        var dAlpha = alphaH - alphaL
        
        // constants from Scipy impl.
        let deltaQ: ScalarT = 0.1
        let deltaC: ScalarT = 0.2
        
        var i = 0
        while i < nStepLengthTrials {
            dAlpha = alphaH - alphaL
            let lBound = min(alphaL, alphaH)
            let uBound = max(alphaL, alphaH)
            
//            falphaL = phi(alphaL)
//            falphaH = phi(alphaH)
//            falphaM = phi(alphaM)
//            
//            falphaL = dPhi(alphaL)
//            falphaH = dPhi(alphaH)
//            falphaM = dPhi(alphaM)
//            
//            falpha = phi(alpha)
//            dfalpha = dPhi(alpha)
            
            // the order of trials is cubic -> quadratic -> bisection
            
            // make sure the interpolated alpha isn't too close to the alphaLo or alphaHi. N.O p62
            // TODO: FUN FACT, in the old impl [08c604acd543d0e352e1b5ad81ece6b221aaf038].
            // if we break right after this, everything seems to work
            
            let cAlpha = cubicInterpolate(alphaL, alphaH, alphaM)
            alpha = lBound <= cAlpha && cAlpha <= uBound ? cAlpha : alphaL
            if abs(alpha - alphaL) < (deltaC * dAlpha)  || abs(alpha - alphaH) < (deltaC * dAlpha) || i == 0 {
                let qAlpha = quadraticInterpolate(alphaL, alphaH)
                alpha = lBound <= qAlpha && qAlpha <= uBound ? qAlpha : alphaL
                if abs(alpha - alphaL) < (deltaQ * dAlpha)  || abs(alpha - alphaH) < (deltaQ * dAlpha) {
                    alpha = (alphaL + alphaH) / 2.0 // abs(alphaL - alphaH) * 0.5 + min(alphaL, alphaH)
                }
            }
            
            let ø = phi(alpha)
            // if alpha doesn't satisfy Wolfe 1 or alpha yields a higher function value
            // we narrow down the search range
            if (ø > (phi(0) + c1 * alpha * dPhi(0))) || (ø >= phi(alphaL)) {
                alphaM = alphaH
                alphaH = alpha
            } else {
                let π = dPhi(alpha)
                
                //Wolfe 2 condition
                if abs(π) <= -c2 * dPhi(0) {
                    return alpha
                }
                
                if π * (alphaH - alphaL) >= 0 {
                    alphaM = alphaH
                    alphaH = alphaL
                } else {
                    alphaM = alphaL
                }
                
                alphaL = alpha
            }
            i += 1
        }
        return alpha
    }
}

public class SteepestDescentOptimizer<F: ObjectiveFunction>: NewtonOptimizer<F> where F.ScalarT == Float {

    public override func optimize(verbose: Bool) -> (MatrixT, [ScalarT], Int) {
        currentPosition = initX
        var iter = 0
        var currentF: ScalarT = 0.0
        var oldF: ScalarT = 0.0
        var Fs: [ScalarT] = []
        
        while iter < maxIters {
            Xs.append(currentPosition)
            oldF = currentF
            currentF = objective.compute(currentPosition)
            Fs.append(currentF)

            let G = objective.gradient(currentPosition)
            
            currentSearchDirection = -G
            if iter > 0 {
                stepLength = lineSearch(initStepLength, oldF) //  backTrackingSearch(initStepLength) //
            } else {
                stepLength = lineSearch(initStepLength)
            }
            
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
}

public class NewtonOptimizer<F: ObjectiveFunction>: LineSearchOptimizer where F.ScalarT == Float {
    public typealias ObjectiveFunctionT = F
    public typealias ScalarT = Float
    
    public var stepLength: Float = 1.0
    public var initStepLength: Float = 1.0
    public var currentPosition: MatrixT
    public var currentSearchDirection: MatrixT
    public var maxIters = 100
    public var nStepLengthTrials = 50
    public var initX: MatrixT
    public var objective: F
    public var Xs: [MatrixT] = []
    // 0 < c1 < c2 < 1
    public var c1: ScalarT = 0.0001
    public var c2: ScalarT = 0.9
    public var alphaMax: ScalarT
    public var fTol: Float = 1e-5
    
    public init(objective: F, stepLength: ScalarT, initX: MatrixT?, maxIters: Int, fTol: ScalarT = 1e-5, alphaMax: ScalarT = 1.0) {
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
        self.alphaMax = alphaMax
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
            let L = cho_factor(H, "L")
            let G = objective.gradient(currentPosition)
            
            currentSearchDirection = -cho_solve(L, G, "L") // -transpose(inv(H) * G.t)
//            stepLength = backTrackingSearch(alphaMax)
            if iter > 0 {
                stepLength = lineSearch(alphaMax, oldF)
            } else {
                stepLength = lineSearch(alphaMax)
            }
            
            if dPhi(0) >= 0 || phi(0) < phi(stepLength) {
                if verbose {
                    print("iter: ", iter, ", f: ", currentF, ", alpha: ", stepLength, "Not a descent step!")
                    break
                }
            }
            
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
    
    // inv(B)
    public var H: MatrixT
    public var gTol: ScalarT
    public var flagInitH: Bool
    
    // control the initialisation of H ~ inv(B)
    public var beta: ScalarT
    
    public init(objective: F, stepLength: ScalarT, initX: MatrixT?, initH: MatrixT?, gTol: ScalarT, maxIters: Int, fTol: ScalarT = 1e-5, alphaMax: ScalarT=1.0, beta: ScalarT=1.0) {
        if initH == nil {
            // N.O p142
            H = eye(objective.dims) * beta
            flagInitH = false
        } else {
            H = initH!
            flagInitH = true
        }
        self.gTol = gTol
        self.beta = beta
        super.init(objective: objective, stepLength: stepLength, initX: initX, maxIters: maxIters, fTol: fTol, alphaMax: alphaMax)

    }
    
    public override func optimize(verbose: Bool) -> (MatrixT, [Float], Int) {
        var iter = 0
        var g = objective.gradient(currentPosition)
        var oldG = g
        var oldPosition = currentPosition
        let I: MatrixT = eye(H.rows)
        var currentF: ScalarT = objective.compute(currentPosition)
        var oldF: ScalarT = currentF
        var nSameF = 0
        
        let outputFmt = "iter: %d, f: %f, alpha: %f"
        if verbose == true {
            print(String(format: outputFmt, 0, currentF, stepLength))
        }
        Xs = [currentPosition]
        while norm(g, "F") > gTol && iter < maxIters {
            oldF = currentF
            currentF = objective.compute(currentPosition)
            
            currentSearchDirection = -transpose(H * g.t)
            
            if iter > 0 {
                stepLength = lineSearch(alphaMax, oldF)
            } else {
                stepLength = lineSearch(alphaMax)
            }
//            stepLength = backTrackingSearch(initStepLength)
            
            if stepLength < 1e-9 || stepLength > 1e8 {
                if verbose {
                    print("WEIRD STEP LENGTH!")
                    print(String(format: outputFmt, iter, currentF, stepLength))
//                    stepLength = 1e-5
                }
                break
            }
            
            if dPhi(0) >= 0 || phi(0) < phi(stepLength) {
                if verbose {
                    print("NOT A DESCENT STEP!")
                }
            }
            
            currentPosition = currentPosition + stepLength * currentSearchDirection
            Xs.append(currentPosition)
            
            g = objective.gradient(currentPosition)
            let sk = currentPosition - oldPosition
            let yk = g - oldG
            
            // update H0 according N.O book p143 eq6.20
            if iter == 0 && !flagInitH {
                let a = (yk * sk.t)[0, 0]
                let b =  (yk * yk.t)[0, 0]
                H = (a / b) * I
            }
            
            let rhok = (1.0 / (yk * sk.t))[0, 0]
            
            //BFGS N.O p140
            let v = (I - rhok * sk.t * yk)
            H = v * H * v.t + rhok * sk.t * sk
            
            if verbose == true {
                print(String(format: outputFmt, iter, currentF, stepLength))
            }
            
            if abs(oldF - currentF) < fTol {
                if nSameF > 5 {
                    print("converged by relative function reduction!")
                    break
                } else {
                    nSameF += 1
                }
            }
            
            oldG = g
            oldPosition = currentPosition
            iter += 1
        }
        
        return (currentPosition, [0.0], iter)
    }
}


