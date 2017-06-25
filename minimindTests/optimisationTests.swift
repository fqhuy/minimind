//
//  optimisationTests.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/21/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import XCTest
@testable import minimind

class  Rosenbrock: ObjectiveFunction {
    public typealias ScalarT = Float
    public typealias MatrixT = Matrix<ScalarT>
    
    func compute(_ x: Matrix<Float>) -> Float {
        return 100.0 * powf(x[0, 1] - powf(x[0, 0], 2), 2) + powf(1.0 - x[0, 1], 2)
    }
    
    func gradient(_ x: Matrix<Float>) -> Matrix<Float> {
        let gX1 = -400.0 * x[0, 0] * (x[0, 1] - powf(x[0, 0], 2)) - 2.0 * (1.0 - x[0, 0])
        let gX2 = 200.0 * (x[0, 1] - powf(x[0, 0], 2))
        return Matrix<Float>([[gX1,  gX2]])
    }
    
    func hessian(_ x: Matrix<Float>) -> Matrix<Float> {
        let h11 = 1200.0 * powf(x[0, 0], 2) - 400.0 * x[0, 1] + 2.0
        let h12 = -400.0 * x[0, 0]
        return Matrix<Float>([[ h11, h12], [-400.0 * x[0, 0], 200.0 ] ])
    }
}

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
        return MatrixT([[2.0 * a * x[0,0] + b]])
    }
    
    public func hessian(_ x: Matrix<Float>) -> Matrix<Float> {
        return MatrixT([[2.0 * a]])
    }
}

class optimisationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRosenbrock() {
        let rb = Rosenbrock()
        let optimizer = NewtonOptimizer(objective: rb, stepLength: 1.0, initX: Matrix<Float>([[5.2, 1.2]]), maxIters: 200)
        let (x, _, _) = optimizer.optimize(verbose: true)
        
//        let optimizer = SCG(objective: rb, learning_rate: 0.01, init_x: Matrix<Float>([[-1.2, 1.0]]), maxiters: 100)
//        let (x, _, _) = optimizer.optimize(verbose: true)
        print(x)
    }

    func testSCG() {
        let scg = SCG(objective: Quad(2.0, -3.0, 5.0), learning_rate: 0.01, init_x: Matrix<Float>([[5.0]]), maxiters: 200)
        let (x, _, _) = scg.optimize(verbose: true)
        print(x)
    }
    
    func testNewton() {
        let optimizer = NewtonOptimizer(objective: Quad(2.0, -3.0, 5.0), stepLength: 5.0, initX: Matrix<Float>([[10.0]]), maxIters: 100)
        let (x, _, _) = optimizer.optimize(verbose: true)
        print(x)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
