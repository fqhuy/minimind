//
//  metricsTests.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/15/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import XCTest
@testable import minimind

class metricsTests: XCTestCase {
    var X = Matrix<Float>([[0.0, 0.5],[1.0, 2.0],[5.0, 10.0]])
    var Y = Matrix<Float>([[4.0, 1.0],[3.0, 2.0]])
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        print(euclideanDistances(X: X, Y: Y))
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
