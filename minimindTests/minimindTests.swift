//
//  minimindTests.swift
//  minimindTests
//
//  Created by Phan Quoc Huy on 3/14/16.
//  Copyright © 2016 Phan Quoc Huy. All rights reserved.
//

import XCTest
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
        let kern = RBF(variance: 1.1, lengthscale: 1.0)
        let gpr = GaussianProcessRegressor<Float, RBF>(kernel: kern, alpha: 1.01)
        
        var X: Matrix<Float> = randMatrix(N, P + 1) * 10.0
        X[column: 0] = ones(N, 1) // [Float](repeating: 1.0, count: N)
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
    
    func testDist(){
        let N = 40
        let Nf = 10
        let w = Float(300.0)
        
        let x: [Float] = arange(0.0, w, w / Float(N))
        
        var s1 = sin(x)
        var s2 = cos(x)
        
        s1 -= s1.mean(); s1 /= s1.std()
        s2 -= s2.mean(); s2 /= s2.std()
        
        let kern = RBF(variance: 10.0, lengthscale: 10000.0)
        let A = kern.K(Matrix<Float>(N, 1, s1), Matrix<Float>(N, 1, s2))
        
//        let (m1, m2) = (Matrix<Float>(N, 1, s1), Matrix<Float>(N, 1, s2))
//        let A = 10.0 * m1 * m2.t
        let v: Matrix<Float> = zeros(1, N)
        
        let gauss = MultivariateNormal(v, A)
        let X: Matrix<Float> = gauss.rvs(Nf) + 100.0
        print(X[0])
    }
    
    func testMatrixOps() {
        let A = Matrix<Float>([[1.0, 0.1, 0.1],[0.01, 2.0, 0.3], [0.02, 0.2, 1.5]])
        let v = Matrix<Float>([[0.0, 0.0, 0.0]])
        
        let gauss = MultivariateNormal(v, A)
        
        let X = gauss.rvs(1000)
        print(X.mean(0))
        
        gauss.pdf(randMatrix(5, 3))
    }
    
    func testArray() {
        let mat: Matrix<Float> = randMatrix(5, 5)
        var m1 = mat
        m1[0, 0] = 100.0
//        print(m1 == mat)
        
        let ids = 0∷10
        
//        let m1 = mat[0..2, 0..2]
    }
    
    func testMath() {
        let m: Matrix<Float>  = Matrix([[1.0, 0.1, 0.1],[0.01, 2.0, 0.3], [0.02, 0.2, 1.5]])
        //        let mat = m * m.t + eye(3)
        
        let (eivals, eivecs) = eigh(m, "L")
        
        for i in 0..<3 {
            print( eivecs[column: i].grid.norm())
        }
        print(eivals)
        
        
        let arr: [Float] = randArray(n: 1000)
        print(arr.mean())
        //        print(eivecs)
        //        let L = cholesky(mat)
    }
    
    func testGP() {
        let N = 8
        let P = 2
//        let w = Float(300.0)
        let w = Float.pi * 2.0
        
//        var X: Matrix<Float> = randMatrix(N, 2)
//        var _y: [Float] = X[column: 0] * X[column: 1] + X[column: 1] + randArray(n: N) * 0.05
//        var y = Matrix<Float>(N, 1, _y)
        
//        var y: [Float] = sin(X[column: 0]) * sin(X[column: 1]) + randArray(n: N) * 0.05
//
//        X[column: 0] -= X[column: 0].mean(); X[column: 0] /= X[column: 0].std()
//        X[column: 1] -= X[column: 1].mean(); X[column: 1] /= X[column: 1].std()

        let X = Matrix<Float>([[-0.91261869,  1.85426673],
            [ 1.34207648, -1.08250752],
            [ 1.13998253,  0.69448722],
            [ 0.40357421, -0.4739292 ],
            [ 0.81214299, -1.23548637],
            [-0.7030745,  -0.78750967],
            [-0.50155067,  0.464332  ],
            [-1.58053235,  0.56634682]])
        
        let y = Matrix<Float>([[0.21198747,  0.0883193,   0.4570866,   0.17492527,  0.03589,     0.06420726,
            0.19189653,  0.03121346]]).t
        
        let kern = RBF(variance: 250, lengthscale: 1000.0)
        let gpr = GaussianProcessRegressor<Float, RBF>(kernel: kern, alpha: 1.0)
        
        gpr.fit(X, y, maxiters: 500)
        
        print(gpr.kernel.K(X, X))
        
//        let Xstar: Matrix<Float> = randMatrix(5, P)
//        let (Mu, Sigma) = gpr.predict(Xstar)
//        
//        print(Mu)
//        print(Sigma)
        
        print(kern.variance)
        print(kern.lengthscale)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
