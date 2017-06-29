//
//  decompositionTests.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/16/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import XCTest
@testable import minimind

class decompositionTests: XCTestCase {
    let N: Int = 20
    let D: Int = 10
    let Q: Int = 2
    
    var Y: Matrix<Float> = Matrix()
    var X: Matrix<Float> = Matrix()

    override func setUp() {
        super.setUp()
        self.Y = zeros(N, D)
        self.X = zeros(N, Q)
        
        let cov = Matrix<Float>([[1.0, 0.1],[0.1, 1.0]])
        let mean1 = Matrix<Float>([[-3, 0]])
        let mean2 = Matrix<Float>([[3, 0]])
        
        let X1 = MultivariateNormal(mean: mean1, cov: cov).rvs(N / 2)
        let X2 = MultivariateNormal(mean: mean2, cov: cov).rvs(N / 2)
        
        let xx = vstack([X1, X2])
        X = xx .- xx.mean(0)
        X = X ./ X.std(0)
        
        let A: Matrix<Float> = randMatrix(2, D)
        Y = X * A + 0.01 * randMatrix(N, D)
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testPCA() {
        let pca = PCA(2)
        pca.fit(Y)
        let X = pca.predict(Y)
        
        print(X)
    }
    
    func testGPLVM() {
        let pca = PCA(Q)
        pca.fit(Y)
        let initX = pca.predict(Y)
        
        let kern = RBF(variance: 1.0, lengthscale: 1.0, X: initX, trainables: ["logVariance", "logLengthscale", "X"])
        let gp = GaussianProcessRegressor<RBF>(kernel: kern, alpha: 0.8)
        gp.fit(X, Y, maxiters: 1000)
        
        print(gp.kernel.variance, gp.kernel.lengthscale)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
