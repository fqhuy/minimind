//
//  clusterTests.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/12/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import XCTest
@testable import minimind

class clusterTests: XCTestCase {
    var X: Matrix<Float> = zeros(100, 2)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let cov = Matrix<Float>([[1.0, 0.1],[0.1, 1.0]])
        let mean1 = Matrix<Float>([[-3, 0]])
        let mean2 = Matrix<Float>([[3, 0]])
        
        let X1 = MultivariateNormal(mean: mean1, cov: cov).rvs(50)
        let X2 = MultivariateNormal(mean: mean2, cov: cov).rvs(50)
        
        let xx = vstack([X1, X2]) 
        X = xx .- xx.mean(0)
        X = X ./ X.std(0)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testKMeansPlusPlus() {
        
        let XSquaredNorm = (X ∘ X).sum(1)
        let clusters = KMeans.kMeansPlusPlus(X, XSquaredNorm, 2, 5)
        print(clusters)
//        print(X)
    }
    
    func testKMeans() {
        let km = KMeans(2, 0.01)
        km.fit(X, 200, true)
        print(km.clusterCenters)
        print(km.labels)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
