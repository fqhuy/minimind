//
//  cg.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/22/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import Foundation

public class ConjugateGradient<F: ObjectiveFunction>: Optimizer where F.ScalarT == Float {
    public var objective: F
    public typealias ObjectiveFunctionT = F
    
    public init(objective: F) {
        self.objective = objective
    }

    public func getCost() -> Double {
        fatalError()
    }

    public func optimize(verbose: Bool) -> (MatrixT, [Float], Int) {
        //MARK: N.O p59 trick to init alpha0, should be in Conjugate Gradient instead
        //            if k > 0 {
        //                 alpha0 = stepLength * oldDPhi / dPhi(0.0)
        ////                alpha0 = 2 * (currentF - oldF) / dPhi(0.0)
        //            } else {
        //                alpha0 = alphaMax
        //            }
        fatalError()
    }

    public typealias ScalarT = Float

    
}
