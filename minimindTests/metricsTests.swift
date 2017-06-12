//
//  metricsTests.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/12/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import XCTest
@testable import minimind

class metricsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEuclideanDistances() {
        let v =  Matrix<Float>([[0.0, 1.0]])
        let a = Matrix<Float>([[0.0, 0.0], [2.0, 1.0]])
        
        print(euclideanDistances(X: v, Y: a, YNormSquared: nil, squared: true, XNormSquared: nil))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
