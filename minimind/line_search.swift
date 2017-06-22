//
//  line_search.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/19/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation

public protocol LineSearchOptimizer: Optimizer {
    var stepLength: ScalarT {get set}
    var currentSearchDirection: MatrixT {get set}
}

public class NewtonOptimizer<F: ObjectiveFunction>: LineSearchOptimizer where F.ScalarT == Float {
    public typealias ScalarT = Float
    
    public var stepLength: Float = 1.0
    public var currentSearchDirection: Matrix<Float>
    public var maxIters = 100
    public var initX: Matrix<Float>
    public var objective: F
    public var Xs: [Matrix<Float>] = []
    
    public init(objective: F, stepLength: ScalarT, initX: Matrix<Float>, maxIters: Int) {
        self.stepLength = stepLength
        self.currentSearchDirection = Matrix<Float>([[0, 0]])
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
            print("iter: ", iter, ", f: ", currentF)
            
        }
        Xs.append(currentX)
        return (currentX, Fs, iter)
    }
    
    public func getCost() -> Double {
        return 0.0
    }

}
