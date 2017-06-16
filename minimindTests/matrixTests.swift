//
//  matrixTests.swift
//  minimind
//
//  Created by Phan Quoc Huy on 6/12/17.
//  Copyright © 2017 Phan Quoc Huy. All rights reserved.
//

import XCTest
@testable import minimind

class matrixTests: XCTestCase {
    var x: Matrix<Int> = Matrix([[0, 0],[4, 5]])
    var y: Matrix<Int> = Matrix([[4, 4], [2, 2]])
    var z: Matrix<Int> = Matrix([[0, 1],[2, 3], [4, 5]])
    
    var fx: Matrix<Float> = Matrix([[0.0, 1.0],[1.0, 1.0]])
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testComparisions() {
        XCTAssert(all(x == x), "matrix equality failed")
        XCTAssert(all(x < x + 1), "matrix inequality failed")
        XCTAssert(all(x > x - 1), "matrix inequality failed")
        XCTAssert(all(x + 2 == 2 + x), "matrix add failed")
        XCTAssert(all(x * 2 == 2 * x), "matrix mul failed")
        XCTAssert(all((y / 2) == Matrix([[2, 2],[1, 1]])), "matrix div failed")
//        XCTAssert(all(x - 2 == -1 * (2 - x) ), "matrix sub failed")
    }
    
    func testArithmetic() {
        XCTAssert(all(fx.mean(0) == Matrix<Float>([[0.5, 1.0]])), " matrix mean failed")
        XCTAssert(all(fx.std(0) == Matrix<Float>([[0.5, 0.0]])), " matrix std failed")
        XCTAssert(all(fx.sum(0) == Matrix<Float>([[1.0, 2.0]])), " matrix sum failed")
    }
    
    func testTransformation() {
        print(x.t)
        XCTAssert(all(x == x.t.t), "matrix transpose failed")
        XCTAssert(all(x.reshape([1, -1]) == x.reshape([1, 4])))
    }
    
    func testOperator() {
        let re = Matrix([[1, 2],[3, 4],[5 ,6]])
        let v1: Matrix<Int> = Matrix([[1 ,1]])
        let v2: Matrix<Int> = Matrix([[1 ,1, 1]])
        XCTAssert(all((z .+ v1) == re))
        XCTAssert(all((z |+ v2) == re))
    }
    
    func testMath() {
        let re2 = Matrix<IndexType>([[1], [1], [1]])
        XCTAssert(all(argmax(z, 0) == Matrix<IndexType>([[2, 2]])))
        XCTAssert(all(argmax(z, 1) == re2))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
