//
//  scaled_conjugate_gradient.swift
//  minimind
//
//  Created by Phan Quoc Huy on 5/28/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation
//import Surge

public class SCG<F: ObjectiveFunction>: Optimizer where F.ScalarT == Float {
    public typealias ObjectiveFunctionT = F
    public typealias ScalarT = Float

    typealias T = ScalarT
    public var objective: F
    var initX: MatrixT
    public var Xs: [MatrixT] = []
    var maxIters: Int
    var verbose: Bool = false
    
    public init(objective: F, learningRate: Float, initX: MatrixT, maxIters: Int = 200) {
        self.objective = objective
        self.initX = initX
        self.maxIters = maxIters
    }
    
    public func optimize(verbose: Bool = false) -> (MatrixT, [Float], Int) {
        let xtol: T = 1e-12
        let ftol: T = 1e-12
        let gtol: T = 1e-12
        let max_f_eval = 10000
        
        let sigma0: T = 1.0e-7
        var fold: T = self.objective.compute(self.initX)
        var function_eval = 1
        var fnow = fold
        var gradnew: MatrixT = self.objective.gradient(self.initX)
        function_eval += 1
        
        var current_grad = (gradnew * gradnew.t)[0, 0]
        
        // NEED TO COPY !
        var gradold: MatrixT = gradnew
        var d = -1 * gradnew
        var success = true
        var nsuccess = 0
        
        let betamin: T = 1.0e-10
        let betamax: T = 1.0e10
        var status = "Not Converged"
        
        var flog = [Float]()
        var iteration = 0
        var delta: T = 0.0
        var theta: T = 0.0
        var kappa: T = 0.0
        var sigma: T = 0.0
        var alpha: T = 0.0
        var beta: T = 1.0
        var Gamma: T = 0.0
        var mu: T = 0.0
        var x = self.initX
        var xnew: MatrixT
        var fnew: T = 0.0
        Xs.append(x)
        while iteration < self.maxIters {
            if success {
                mu = (d * gradnew.t)[0, 0]
                if mu >= 0 {
                    d = -gradnew
                    mu = (d * gradnew.t)[0, 0]
                }
                kappa = (d * d.t)[0, 0]
                sigma = sigma0 / sqrt(kappa)
                
                let xplus = x + sigma * d
                let gplus = self.objective.gradient(xplus)
                function_eval += 1
                theta = (d * (gplus - gradnew).t / sigma)[0, 0]
            }
            
            delta = theta + beta * kappa
            if delta <= 0 {
                delta = beta * kappa
                beta = beta - theta / kappa
            }
            
            alpha = -mu / delta
            
            xnew = x + alpha * d
            fnew = self.objective.compute(xnew)
            function_eval += 1
            
            if function_eval >= max_f_eval{
                print("max_f_eval reached")
                return (x, flog, function_eval)
            }
            
            let Delta = 2.0 * (fnew - fold) / (alpha * mu)
            if Delta >= 0 {
                success = true
                nsuccess += 1
                x = xnew
                Xs.append(x)
                fnow = fnew
            } else {
                success = false
                fnow = fold
            }
            
            flog.append(fnow)
            
            iteration += 1
            if verbose {
                // show current values
                print("iter: ", iteration, fnow)
            }
            
            if success {
                if abs(fnew - fold) < ftol {
                    status = "converged - relative reduction in objective"
                    break
                } else if max(abs(alpha * d)) < xtol {
                    status = "converged - relative stepsize"
                    break
                } else {
                    gradold = gradnew
                    gradnew = self.objective.gradient(x)
                    function_eval  += 1
                    current_grad = (gradnew * gradnew.t)[0, 0]
                    fold = fnew
                    
                    if current_grad <= gtol {
                        status = "converged - relative reduction in gradients"
                        break
                    }
                }
            }
            
            if Delta < 0.25 {
                beta = min([4.0 * beta, betamax])
            }
            
            if Delta > 0.75 {
                beta = max([025 * beta, betamin])
            }
            
            if nsuccess == x.size {
                d = -gradnew
                beta = 1.0
                nsuccess = 0
            } else if success {
                Gamma = ((gradold - gradnew) * gradnew.t)[0, 0] / mu
                d = Gamma * d - gradnew
            }
        }
        if iteration == maxIters {
            status = "maxiter exceeded"
        }
        if verbose {
            print("iter: ", iteration, fnow)
            print(status)
        }
        
        return (x, flog, function_eval)
    }
    
    public func getCost() -> Double {
        return 0.0
    }
}
