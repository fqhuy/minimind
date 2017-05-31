//
//  minimindTests.swift
//  minimindTests
//
//  Created by Phan Quoc Huy on 3/14/16.
//  Copyright © 2016 Phan Quoc Huy. All rights reserved.
//

import XCTest
import Surge
@testable import minimind

class minimindTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        let kern = RBF(alpha: 0.1, gamma: 2.0)
        let gpr = GaussianProcessRegressor<Float, RBF>(kernel: kern, alpha: 0.01)
        
        let X: Matrix<Float> = randMatrix(rows: 10, columns: 5)
        let y: Matrix<Float> = randMatrix(rows: 1, columns: 10)
        
        gpr.fit(X, y)
        let Xstar: Matrix<Float> = randMatrix(rows: 2, columns: 5)
        gpr.predict(Xstar)
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
