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
    
    func testGaussianProcessRegressor() {
        let N = 8
        let P = 2
        let kern = RBF(alpha: 1.1, gamma: 1.0)
        let gpr = GaussianProcessRegressor<Float, RBF>(kernel: kern, alpha: 1.01)
        
        var X: Matrix<Float> = randMatrix(N, P + 1) * 10.0
        X[column: 0] = [Float](repeating: 1.0, count: N)
        var XX: Matrix<Float> = zeros(N, P)
        for i in 1..<P+1 {
            XX[column: i - 1] = X[column: i]
        }
        
        let A: Matrix<Float> = randMatrix(P + 1, 1)
        let y: Matrix<Float> = X * A + 0.01 * randMatrix(N, 1)
        
        gpr.fit(XX, y)
        
        let Xstar: Matrix<Float> = randMatrix(5, P)
        let (Mu, Sigma) = gpr.predict(Xstar)
        
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
    
    func testMatrixOps() {
        let X: Matrix<Float> = randMatrix(8, 2)
        let y: Matrix<Float> = randMatrix(8, 1)
        let kern = RBF(alpha: 1.1, gamma: 1.0)
        
        let C = kern.K(X, X) + eye(8) * (1.1 * 1.1)
        let N = Float(X.rows)
        let D = Float(X.columns)
        
        let L = cholesky(C, "L")
        let alpha = solve_triangular(L,y, "L")
        
        let ytCy = 0.5 * reduce_sum(alpha • alpha)![0, 0]
        let logdetC = 0.5 * D * logdet(C)
        
        let llh = ytCy + logdetC + N * D / 2.0 * log(2.0 * Float.pi)
        
    }
    
    func testMath() {
        let m: Matrix<Float>  = randMatrix(4, 3)
        let mat = m * m.t
        
        let L = cholesky(mat)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
