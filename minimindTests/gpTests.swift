//
//  gpTests.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/26/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import XCTest
@testable import minimind

class gpTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    
    func testGaussianProcessRegressor() {
        let N = 8
        let Nf = 20
        let X = Matrix<Float>([[-1.50983293], [-1.11726642], [-0.89303372], [ 0.07971517], [ 0.29116607], [ 0.7494249 ], [ 0.93321463], [ 1.46661229]])
        
        let Y = Matrix<Float>([[ 0.04964821,  0.0866106,  0.16055375,  0.58936555,  0.71558366,  1.00004714,  1.08412273,  1.42418915]]).t
        
        let kern = RBF(variance: 400, lengthscale: 1000, X: X, trainables: ["logVariance", "logLengthscale"])
        let gp = GaussianProcessRegressor<RBF>(kernel: kern, alpha: 1.0)
        gp.fit(X, Y, maxiters: 500)
        
        print(gp.kernel.getParams())
        
        let Xstar = Matrix<Float>(-1, 1, arange(-1.5, 1.5, 0.1))
        let (Mu, Sigma) = gp.predict(Xstar)
        
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
