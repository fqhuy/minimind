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
    var Y: Matrix<Float> = zeros(100, 15)

    override func setUp() {
        super.setUp()
        
        let cov = Matrix<Float>([[1.0, 0.1],[0.1, 1.0]])
        let mean1 = Matrix<Float>([[-3, 0]])
        let mean2 = Matrix<Float>([[3, 0]])
        
        let X1 = MultivariateNormal(mean: mean1, cov: cov).rvs(50)
        let X2 = MultivariateNormal(mean: mean2, cov: cov).rvs(50)
        
        let xx = vstack([X1, X2])
        var X = xx .- xx.mean(0)
        X = X ./ X.std(0)
        
        let A: Matrix<Float> = randMatrix(2, 15)
        Y = X * A + 0.01 * randMatrix(100, 15)
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

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
