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
    
    func testSCG() {
        class Quad: ObjectiveFunction {
            typealias ScalarT = Float
            typealias MatrixT = Matrix<ScalarT>
            
            public var a: ScalarT
            public var b: ScalarT
            public var c: ScalarT
            
            public init(_ a: ScalarT, _ b: ScalarT, _ c: ScalarT) {
                self.a = a
                self.b = b
                self.c = c
            }
            
            public func compute(_ x: MatrixT) -> ScalarT {
                return a * x[0, 0] * x[0,0] + b * x[0,0] + c
            }
            
            public func gradient(_ x: MatrixT) -> MatrixT {
                return MatrixT([[2 * a * x[0,0] + b]])
            }
        }
        
        var scg = SCG(objective: Quad(2.0, -3.0, 5.0), learning_rate: 0.01, init_x: Matrix<Float>([[5.0]]), maxiters: 200)
        scg.optimize(verbose: true)

    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
